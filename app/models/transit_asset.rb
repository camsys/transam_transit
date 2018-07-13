class TransitAsset < TransamAssetRecord

  acts_as :transam_asset, as: :transam_assetible

  actable as: :transit_assetible

  after_save :save_to_asset

  belongs_to :asset
  belongs_to :fta_asset_category
  belongs_to :fta_asset_class
  belongs_to :fta_type,  :polymorphic => true
  belongs_to :contract_type

  # each transit asset has zero or more maintenance provider updates. .
  has_many    :maintenance_provider_updates, -> {where :asset_event_type_id => MaintenanceProviderUpdateEvent.asset_event_type.id }, :class_name => "MaintenanceProviderUpdateEvent",  :foreign_key => :transam_asset_id

  # Each asset can be associated with 0 or more districts
  has_and_belongs_to_many   :districts,  :foreign_key => :transam_asset_id

  FORM_PARAMS = [
      :fta_asset_category_id,
      :fta_asset_class_id,
      :global_fta_type,
      :pcnt_capital_responsibility,
      :contract_num,
      :contract_type_id,
      :has_warranty,
      :warranty_date
  ]

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

  # old asset
  def typed_asset
    Asset.get_typed_asset(asset)
  end

  # in single table inheritance we could always pull fuel_type_id cause it would just be nil on assets that didn't have a fuel type
  # we often wrote logic on that assumption so therefore this method ensures that there is always a fuel type id even if it doesn't exist in the database table now that we've moved to class table inheritance
  # a very specific class would respond to this if it exists in the database table
  # if it doesn't, it will try what it acts_as and will eventually hit this method
  def fuel_type_id
    nil
  end

  # https://neanderslob.com/2015/11/03/polymorphic-associations-the-smart-way-using-global-ids/
  # following this article we set fta_type based on the fta asset class ie the model
  def global_fta_type
    self.fta_type.to_global_id if self.fta_type.present?
  end

  def global_fta_type=(fta_type)
    self.fta_type=GlobalID::Locator.locate fta_type
  end

  def tam_performance_metric
    metric = nil

    asset_level = fta_asset_category.asset_levels(Asset.where(object_key: self.object_key))

    TamPolicy.all.each do |policy|
      metric = policy.tam_performance_metrics.includes(:tam_group).where(tam_groups: {organization_id: self.organization_id, state: 'activated'}).where(asset_level: asset_level).first
      break if metric.present?
    end

    metric
  end

  def useful_life_benchmark
    if self.try(:direct_capital_responsibility) && tam_performance_metric.try(:useful_life_benchmark)
      tam_performance_metric.useful_life_benchmark + (tam_performance_metric.useful_life_benchmark_unit == 'year' ? (rehabilitation_updates.sum(:extended_useful_life_months) || 0)/12 : 0)
    end
  end

  def useful_life_remaining(date=Date.today)
    if useful_life_benchmark && tam_performance_metric.try(:useful_life_benchmark_unit) == 'year'
      useful_life_benchmark - (date.year - manufacture_year)
    end
  end

  protected

  def save_to_asset
    # only need to these field in old assets table to tie properly to policy
    if (previous_changes.keys.include? 'asset_subtype_id') || (previous_changes.keys.include? 'fuel_type_id')
      asset.update!(previous_changes)
    end
  end
end
