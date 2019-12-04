class TransitAsset < TransamAssetRecord

  include MaintainableAsset
  
  acts_as :transam_asset, as: :transam_assetible

  actable as: :transit_assetible

  belongs_to :asset
  belongs_to :fta_asset_category
  belongs_to :fta_asset_class
  belongs_to :fta_type,  :polymorphic => true
  belongs_to :contract_type
  belongs_to  :operator, :class_name => 'Organization'
  belongs_to  :title_ownership_organization, :class_name => 'Organization'
  belongs_to  :lienholder, :class_name => 'Organization'

  # each transit asset has zero or more maintenance provider updates. .
  has_many    :maintenance_provider_updates, -> {where :asset_event_type_id => MaintenanceProviderUpdateEvent.asset_event_type.id }, :class_name => "MaintenanceProviderUpdateEvent",  :as => :transam_asset

  # Each asset can be associated with 0 or more districts
  has_and_belongs_to_many   :districts,  :foreign_key => :transam_asset_id, :join_table => :assets_districts

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :fta_asset_category_id, presence: true
  validates :fta_asset_class_id, presence: true
  validates :fta_type_id, presence: true
  validates :manufacturer_id, inclusion: {in: Manufacturer.where(code: 'ZZZ').pluck(:id)}, if: Proc.new{|a| a.manufacturer_id.present? && a.other_manufacturer.present?}
  validates :manufacturer_model_id, inclusion: {in: ManufacturerModel.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.manufacturer_model_id.present? && a.other_manufacturer_model.present?}
  validates   :pcnt_capital_responsibility, :allow_nil => true, :numericality => {:only_integer => true,   :greater_than => 0, :less_than_or_equal_to => 100}


  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  FORM_PARAMS = [
      :fta_asset_category_id,
      :fta_asset_class_id,
      :global_fta_type,
      :pcnt_capital_responsibility,
      :contract_num,
      :contract_type_id,
      :has_warranty,
      :warranty_date,
      :operator_id,
      :other_operator,
      :title_number,
      :title_ownership_organization_id,
      :other_title_ownership_organization,
      :lienholder_id,
      :other_lienholder,
  ]

  CLEANSABLE_FIELDS = [

  ]

  SEARCHABLE_FIELDS = [
      :fta_type,
      :title_number
  ]

  callable_by_submodel def self.asset_seed_class_name
    'FtaAssetClass'
  end

  # this method gets copied from the transam asset level because sometimes start at this base
  def self.very_specific
    klass = self.all
    assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
    assoc_arr = Hash.new
    assoc_arr[assoc] = nil
    t = klass.distinct.where.not(assoc_arr).pluck(assoc)

    while t.count == 1 && assoc.present?
      id_col = assoc[0..-6] + '_id'
      klass = t.first.constantize.where(id: klass.pluck(id_col))
      assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
      if assoc.present?
        assoc_arr = Hash.new
        assoc_arr[assoc] = nil
        t = klass.distinct.where.not(assoc_arr).pluck(assoc)
      end
    end

    return klass
  end

  def dup
    super.tap do |new_asset|
      new_asset.grant_purchases = self.grant_purchases
      new_asset.transam_asset = self.transam_asset.dup
    end
  end

  # old asset
  def typed_asset
    Asset.get_typed_asset(asset)
  end

  # https://neanderslob.com/2015/11/03/polymorphic-associations-the-smart-way-using-global-ids/
  # following this article we set fta_type based on the fta asset class ie the model
  def global_fta_type
    self.fta_type.to_global_id if self.fta_type.present?
  end

  def global_fta_type=(fta_type)
    self.fta_type=GlobalID::Locator.locate fta_type
  end

  def direct_capital_responsibility
    new_record? || pcnt_capital_responsibility.present?
  end

  def tam_performance_metric
    metric = nil

    asset_level = fta_asset_category.asset_levels(TransitAsset.where(object_key: self.object_key))

    TamPolicy.all.each do |policy|
      metric = policy.tam_performance_metrics.includes(:tam_group).where(tam_groups: {organization_id: self.organization_id, state: 'activated'}).where(asset_level: asset_level).first
      break if metric.present?
    end

    metric
  end

  def useful_life_benchmark
    # has to be directly responsible and have a ULB/TERM value (infrastructure does not)
    if self.try(:direct_capital_responsibility) && tam_performance_metric.try(:useful_life_benchmark).present?
      tam_performance_metric.useful_life_benchmark + (tam_performance_metric.useful_life_benchmark_unit == 'year' ? (rehabilitation_updates.sum(:extended_useful_life_months) || 0)/12 : 0)
    end
  end

  def useful_life_remaining(date=Date.today)
    if useful_life_benchmark && tam_performance_metric.try(:useful_life_benchmark_unit) == 'year'
      useful_life_benchmark - (date.year - manufacture_year)
    end
  end

  def calculate_term_estimation(on_date)
    if on_date
      TermEstimationCalculator.new.calculate_on_date(self, on_date)
    else
      0
    end
  end

  def term_estimation_js(render_threshold=0.001)
    threshold = self.policy_analyzer.get_condition_threshold
    old_condition = 10.0 # make this impossibly optimal so always can calculate first two term estimates
    new_condition = self.calculate_term_estimation(self.in_service_date)
    js_string = "[new Date(#{js_date(self.in_service_date)}), null, #{new_condition}, #{threshold}]"
    yr_count = 1

    Rails.logger.info "===START===="
    while new_condition >= 1.0 && (old_condition- new_condition) > render_threshold
      old_condition = new_condition
      new_condition = self.calculate_term_estimation(self.in_service_date + yr_count.years)
      js_string += ",[new Date(#{js_date(self.in_service_date + yr_count.years)}), null, #{new_condition}, #{threshold}]"
      yr_count += 1

      Rails.logger.info new_condition
      Rails.logger.info old_condition
      Rails.logger.info new_condition - old_condition
    end
    Rails.logger.info js_string
    Rails.logger.info "===END===="

    return [yr_count, js_string]
  end

  def fta_asset_class_name
    unless self.fta_asset_class.nil?
      return self.fta_asset_class.name
    else
      'Unknown fta asset class'
    end
  end

  def fta_type_description
    unless self.fta_type.nil?
      if self.fta_type.class.method_defined? :description
        return self.fta_type.description
      # elsif  self.fta_type.class.method_defined? :name
      #   return self.fta_type.name
      # elsif  self.fta_type.class.method_defined? :code
      #   return self.fta_type.code
      end
    else
      return fta_type.class
    end
  end

  def organization_name
    self.organization.name
  end

  def manufacturer_name
    unless self.other_manufacturer.nil?
      return self.other_manufacturer
    else
      if self.manufacturer
        return self.manufacturer.code + ' - ' + self.manufacturer.name
      else
        nil
      end
    end
  end

  def manufacturer_model_name
    unless self.other_manufacturer_model.nil?
      return self.other_manufacturer_model
    else
      if self.manufacturer_model
        return self.manufacturer_model.name
      else
        nil
      end
    end
  end

  def reported_condition_rating_string
    return reported_condition_rating.to_s
  end

  def reported_condition_type_name
    return reported_condition_type.name
  end

  def most_recent_update_early_disposition_request_comment
    early_disposition_request = self.early_disposition_requests.where(state: 'new').order("updated_at asc").first

    unless early_disposition_request.nil?
      return early_disposition_request.comments
    end

  end

  def as_json(options={})
    super.merge(
        {
            :fta_asset_class_name => self.fta_asset_class_name,
            :fta_type_description => self.fta_type_description,
            :organization_name => self.organization_name,
            :manufacturer_name => self.manufacturer_name,
            :manufacturer_model_name => self.manufacturer_model_name,
            :reported_condition_rating_string => self.reported_condition_rating_string,
            :reported_condition_type_name => self.reported_condition_type_name,
            :most_recent_update_early_disposition_request_object_key => self.early_disposition_requests.where(state: 'new').order("updated_at asc").first.try(:object_key),
            :most_recent_update_early_disposition_request_comment => self.most_recent_update_early_disposition_request_comment
        })
  end

  protected

  private

  def js_date(date)
    [date.year,(date.month) - 1,date.day].compact.join(',')
  end


end
