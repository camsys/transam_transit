class TransitAsset < TransamAssetRecord

  include ActionView::Helpers::NumberHelper
  include MaintainableAsset
  include TransamFormatHelper
  
  CATEGORIZATION_PRIMARY = 0
  CATEGORIZATION_COMPONENT = 1
  CATEGORIZATION_SUBCOMPONENT = 2

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

  def direct_capital_responsibility_yes_no
    direct_capital_responsibility ? 'Yes' : 'No'
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

  def operational_service_status(date=Date.today)
    typed_org = Organization.get_typed_organization(organization)
    start_date = typed_org.start_of_ntd_reporting_year(typed_org.ntd_reporting_year_year_on_date(date))
    end_date = start_date + 1.year - 1.day

    if TransamAsset.operational_in_range(start_date, end_date).exists?(self.transam_asset.id)
      service_status_event = service_status_updates.where('event_date <= ?', date).last

      if service_status_event.try(:fta_emergency_contingency_fleet)
        return false
      else
        if service_status_event.try(:service_status_type) == ServiceStatusType.find_by_code('O')
          return OutOfServiceStatusType.where('name LIKE ?', "%#{'Short Term'}%").ids.include? service_status_event.out_of_service_status_type_id
        else
          return true
        end
      end
    else
      return false
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
    unless self.other_manufacturer.blank?
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
    if self.manufacturer_model and self.manufacturer_model.name != "Other"
      return self.manufacturer_model.name
    else
      return self.other_manufacturer_model.to_s
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

  def categorization
    return CATEGORIZATION_PRIMARY
  end

  def categorization_string
    case categorization
    when CATEGORIZATION_PRIMARY
      "Primary"
    when CATEGORIZATION_COMPONENT
      "Component"
    when CATEGORIZATION_SUBCOMPONENT
      "Sub-Component"
    end
  end

  def as_json(options={})
    super.merge(
        {
            fta_asset_class_name: self.fta_asset_class_name,
            fta_type_description: self.fta_type_description,
            organization_name: self.organization_name,
            manufacturer_name: self.manufacturer_name,
            manufacturer_model_name: self.manufacturer_model_name,
            reported_condition_rating_string: self.reported_condition_rating_string,
            reported_condition_type_name: self.reported_condition_type_name,
            most_recent_update_early_disposition_request_object_key: self.early_disposition_requests.where(state: 'new').order("updated_at asc").first.try(:object_key),
            most_recent_update_early_disposition_request_comment: self.most_recent_update_early_disposition_request_comment
        })
  end

  ######## API Serializer ##############
  # TODO: Some of these can be promoted to TransamAsset in the Core Engine
  def api_json(options={})
    transam_asset.api_json(options).merge(
    {
      title_number: title_number,
      fta_asset_class: fta_asset_class.try(:api_json, options),
      global_fta_type: global_fta_type.try(:api_json, options), 
      contract_type: contract_type.try(:api_json, options), 
      contract_num: contract_num,
      has_warranty: has_warranty,
      warranty_date: warranty_date,
      operator: operator.try(:api_json, options),
      other_operator: other_operator,
      title_ownership_organization_id: title_ownership_organization_id.try(:api_json, options),
      other_title_ownership_organization: other_title_ownership_organization,
      lienholder: lienholder.try(:api_json, options),
      other_lienholder: other_lienholder,
      pcnt_capital_responsibility: pcnt_capital_responsibility
    })
  end

  def inventory_api_json(options={})
    {
      "organization_id": organization.id,
      "Characteristics^manufacturer": { id: manufacturer.try(:id), val: "#{manufacturer.try(:name)} (#{manufacturer.try(:filter)})"},      
      "Characteristics^manufacturer_other": other_manufacturer,      
      "Characteristics^model": { id: manufacturer_model.try(:id), val: manufacturer_model_name },
      "Characteristics^model_other": other_manufacturer_model,      
      "type": fta_asset_class_name,
      "Identification & Classification^external_id": external_id,
      "Identification & Classification^type": { id: fta_type.id, val: type_name },
      "Identification & Classification^subtype": { id: asset_subtype.try(:id), val: subtype_name, },
      "id": self.transam_asset.id,
      "asset_tag": asset_id,
      "Characteristics^year": manufacture_year,
      "Funding^cost": formatted_purchase_cost,
      "Funding^direct_capital_replacement": formatted_direct_capital_responsibility,
      "Funding^percent_capital_replacement": formatted_pcnt_capital_responsibility,
      "Procurement & Purchase^purchase_date": purchase_date,
      "Procurement & Purchase^purchased_new": purchased_new,
      "Operations^in_service_date": in_service_date,
      "Registration & Title^title_number": title_number,
      "Condition^condition": { id: reported_condition_type.try(:id), val: reported_condition_type_name },
      "Condition^service_status": { id: service_status.try(:id), val: service_status_name },
      # "Identification & Classification^class": { id: fta_asset_class_id, val: fta_asset_class_name },
    }
  end



  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------

  FIELDS = {
    org_name: {label: "Organization", method: :org_name, url: nil},
    manufacturer: {label: "Manufacturer", method: :manufacturer_name, url: nil},
    model: {label: "Model", method: :manufacturer_model_name, url: nil},
    year: {label: "Year", method: :manufacture_year, url: nil},
    type: {label: "Type", method: :type_name, url: nil},
    subtype: {label: "Subtype", method: :subtype_name, url: nil},
    last_life_cycle_action: {label: "Last Life Cycle Action", method: :last_life_cycle_action, url: nil},
    life_cycle_action_date: {label: "Life Cycle Action Date", method: :life_cycle_action_date, url: nil},
    fta_asset_class: {label: "Class", method: :fta_asset_class_name, url: nil},
    external_id: {label: "External ID", method: :external_id, url: nil},
    purchase_cost: {label: "Cost (Purchase)", method: :formatted_purchase_cost, url: nil},
    in_service_date: {label: "In Service Date", method: :in_service_date, url: nil},
    operator: {label: "Operator", method: :transit_operator_name, url: nil},
    direct_capital_responsibility: {label: "Direct Capital Responsibility", method: :formatted_direct_capital_responsibility, url: nil},
    pcnt_capital_responsibility: {label: "Capital Responsibility %", method: :formatted_pcnt_capital_responsibility, url: nil},
    term_condition: {label: "TERM Condition", method: :reported_condition_rating, url: nil},
    term_rating: {label: "TERM Rating", method: :reported_condition_type_name, url: nil},
    location: {label: "Location", method: :location_name, url: nil},
    description: {label: "Description", method: :description, url: nil},
    quantity: {label: "Quantity", method: :quantity, url: nil},
    quantity_unit: {label: "Quantity Type", method: :quantity_unit, url: nil},
    policy_replacement_year_as_fiscal_year: {label: "Policy Replacement Year", method: :formatted_policy_replacement_year},
    scheduled_replacement_year_as_fiscal_year: {label: "Scheduled Replacement Year", method: :formatted_scheduled_replacement_year},
    scheduled_replacement_cost: {label: "Scheduled Replacement Cost", method: :formatted_scheduled_replacement_cost, url: nil}
  }

  def field_library key 
    fields = FIELDS
    fields[:asset_id] = {label: "Asset ID", method: :asset_tag, url: "/inventory/#{self.object_key}/"}
    
    if fields[key]
      return fields[key]
    else 
      return nil # TODO: Replace this if we put a fields_library on the parent
    end

  end

  def formatted_policy_replacement_year
    format_as_fiscal_year policy_replacement_year
  end
  
  def formatted_scheduled_replacement_year
    format_as_fiscal_year scheduled_replacement_year
  end

  def formatted_scheduled_replacement_cost
    number_to_currency(scheduled_replacement_cost, precision: 0)
  end
  
  def formatted_pcnt_capital_responsibility
    if pcnt_capital_responsibility
      return "#{pcnt_capital_responsibility}%"
    end
  end

  def formatted_purchase_cost
    number_to_currency(purchase_cost, precision: 0)
  end

  def formatted_direct_capital_responsibility
    direct_capital_responsibility ? "Yes" : "No"
  end

  def org_name
    organization.try(:short_name)
  end

  def type_name
    fta_type.try(:name)
  end

  def subtype_name
    asset_subtype.try(:name)
  end

  def last_life_cycle_action
    history.first.try(:asset_event_type).try(:name)
  end

  def life_cycle_action_date
    history.first.try(:event_date)
  end

  def fta_asset_class_name
    fta_asset_class.try(:name)
  end

  def transit_operator_name
    operator.try(:short_name)
  end

  def reported_condition_type_name
    reported_condition_type.try(:name)
  end

  def service_status_name
    service_status.try(:service_status_type).try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

  #---
  # Logged methods for updating type info. See TTPLAT-1855
  #---

  def update_type_info(fta_class: nil, fta_type: nil, subtype: nil, user: nil, validate: false)
    if fta_class || fta_type || subtype
      log = AssetTypeInfoLog.new(transam_asset: self, fta_asset_class: self.fta_asset_class, fta_type: self.fta_type,
                                 asset_subtype: self.asset_subtype, creator: user)
      self.fta_asset_class = fta_class if fta_class
      self.fta_type = fta_type if fta_type
      self.asset_subtype = subtype if subtype
      transaction do
        save!
        log.save!
      end
      log
    end
  end

  def revert_type_info
    log = AssetTypeInfoLog.where(transam_asset: self).order(updated_at: :desc).first

    return false unless log
    
    self.fta_asset_class = log.fta_asset_class
    self.fta_type = log.fta_type
    self.asset_subtype = log.asset_subtype
    transaction do
      log.destroy
      save!
    end
    true
  end

  def report_logged_type_info
    output = ["Current Values for #{to_s}",
              "FtaAssetClass: #{fta_asset_class}, FtaType: #{fta_type}, AssetSubtype: #{asset_subtype}",
              "Previous Values"]
    AssetTypeInfoLog.where(transam_asset: self).inject(output) {|output, log| output << log.to_s}
    output.join("\n")
  end

  #-----------------------------------------------------------------------------
  # DotGrants JSON
  #-----------------------------------------------------------------------------
  def dotgrants_json
    {
      asset_tag: asset_tag,
      dotgrants_fuel_type: self.very_specific.try(:fuel_type).try(:dotgrants_json)
    }
  end

  protected

  private

  def js_date(date)
    [date.year,(date.month) - 1,date.day].compact.join(',')
  end


end
