#------------------------------------------------------------------------------
# TransamTransitAsset
#
# Extends the default asset model with transit-specific properties and methods
#
#------------------------------------------------------------------------------
module TransamTransitAsset

  extend ActiveSupport::Concern

  included do

    # Include the maintenance asset mixin
    include MaintainableAsset

    #---------------------------------------------------------------------------
    # Callbacks
    #---------------------------------------------------------------------------
    after_initialize    :set_defaults

    # Clean up any HABTM associations before the asset is destroyed
    before_destroy { districts.clear }

    after_save :check_policy_rule

    #---------------------------------------------------------------------------
    # Associations
    #---------------------------------------------------------------------------

    # each asset uses a funding type
    belongs_to  :fta_funding_type

    # each asset has a single maintenance provider type
    belongs_to  :maintenance_provider_type

    # each transit asset has zero or more maintenance provider updates. .
    has_many    :maintenance_provider_updates, -> {where :asset_event_type_id => MaintenanceProviderUpdateEvent.asset_event_type.id }, :class_name => "MaintenanceProviderUpdateEvent",  :foreign_key => :asset_id

    # Each asset can be associated with 0 or more districts
    has_and_belongs_to_many   :districts,  :foreign_key => :asset_id

    #---------------------------------------------------------------------------
    # Validations
    #---------------------------------------------------------------------------
    # Make sure each asset has a funding type set

    validates   :fta_funding_type,  :presence => true

    validates     :in_service_date,     :presence => true

    validates_uniqueness_of :asset_tag, :scope => :organization, :case_sensitive => false

  end

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  module ClassMethods
    def self.allowable_params
      [
        :fta_funding_type_id
      ]
    end

  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------
  def searchable_fields
    a = []
    a << super
    [].each do |field|
      a << field
    end
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    [].each do |field|
      a << field
    end
    a.flatten
  end

  def update_methods
    a = []
    a << super
    [:update_maintenance_provider].each do |method|
      a << method
    end
    a.flatten
  end

  # Forces an update of an assets maintenance provider. This performs an update on the record.
  def update_maintenance_provider(save_asset = true)

    Rails.logger.info "Updating the recorded maintenance provider for asset = #{object_key}"

    unless new_record?
      if maintenance_provider_updates.empty?
        self.maintenance_provider_type = nil
      else
        event = maintenance_provider_updates.last
        self.maintenance_provider_type = event.maintenance_provider_type
      end
      save if save_asset
    end
  end

  def check_policy_rule

    policy.find_or_create_asset_type_rule self.asset_type

    typed_asset = Asset.get_typed_asset self
    if (typed_asset.respond_to? :fuel_type)
      policy.find_or_create_asset_subtype_rule asset_subtype, typed_asset.fuel_type
    else
      policy.find_or_create_asset_subtype_rule asset_subtype
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

  def fta_asset_category
    FtaAssetCategory.asset_types([self.asset_type]).first
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

  #-----------------------------------------------------------------------------
  protected
  #-----------------------------------------------------------------------------

  def set_defaults
    super

    if self.class.name == "Component"
      self.fta_funding_type ||= FtaFundingType.find_by(name: 'Unknown')
    end
  end

  private
  def js_date(date)
    [date.year,(date.month) - 1,date.day].compact.join(',')
  end

end
