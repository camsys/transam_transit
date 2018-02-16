#------------------------------------------------------------------------------
#
# RollingStock
#
# Abstract class that adds vehicle/rolling stock attributes to the base Asset class.
# All concrete rolling stock assets should be drived from this base class
#
#------------------------------------------------------------------------------
class RollingStock < Asset

  # Callbacks
  after_initialize    :set_defaults
  before_validation   :set_description

  #------------------------------------------------------------------------------
  # Associations common to all rolling stock
  #------------------------------------------------------------------------------

  # each vehicle has a type of fuel
  belongs_to                  :fuel_type
  belongs_to                  :dual_fuel_type

  # each vehicle's title is owned by an organization
  belongs_to                  :title_owner,         :class_name => "Organization", :foreign_key => 'title_owner_organization_id'

  # each has a storage method
  belongs_to                  :vehicle_storage_method_type

  # each vehicle has zero or more operations update events
  has_many   :operations_updates, -> {where :asset_event_type_id => OperationsUpdateEvent.asset_event_type.id }, :class_name => "OperationsUpdateEvent", :foreign_key => "asset_id"

  # each vehicle has zero or more operations update events
  has_many   :vehicle_usage_updates,      -> {where :asset_event_type_id => VehicleUsageUpdateEvent.asset_event_type.id }, :class_name => "VehicleUsageUpdateEvent",  :foreign_key => "asset_id"

  # each asset has zero or more storage method updates. Only for rolling stock assets.
  has_many   :storage_method_updates, -> {where :asset_event_type_id => StorageMethodUpdateEvent.asset_event_type.id }, :class_name => "StorageMethodUpdateEvent", :foreign_key => "asset_id"

  # ----------------------------------------------------
  # Vehicle Physical Characteristics
  # ----------------------------------------------------
  validates :manufacturer_id,     :presence => true
  validates :manufacturer_model,  :presence => true
  validates :title_owner_organization_id,        :presence => true
  validates :rebuild_year,        :numericality => {:only_integer => true,   :greater_than_or_equal_to => 1900},  :allow_nil => true

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :title_number,
      :title_owner_organization_id,
      :expected_useful_miles,
      :reported_milage,
      :rebuild_year,
      :description,
      :vehicle_storage_method_type_id,
      :fuel_type_id,
      :dual_fuel_type_id,
      :other_fuel_type
    ]
  end


  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :title_number => self.title_number,
      :title_owner_organization_id => self.title_owner.present? ? self.title_owner.to_s : nil,
      :expected_useful_miles => self.expected_useful_miles,
      :rebuild_year => self.rebuild_year,
      :vehicle_storage_method_type_id => self.vehicle_storage_method_type.present? ? self.vehicle_storage_method_type.to_s : nil,
      :fuel_type_id => self.fuel_type.present? ? self.fuel_type.to_s : nil
    })
  end

  # Rebuild year is optional so blanks are allowed
  def rebuild_year=(num)
    unless num.blank?
      self[:rebuild_year] = sanitize_to_int(num)
    end
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  # Override the name property
  def name
    super
  end

  # The cost of a vehicle is the purchase cost
  def cost
    purchase_cost
  end

  def searchable_fields
    a = []
    a << super
    a += [:title_number]
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    a += ['title_number', 'description']
    a.flatten
  end

  def update_methods
    a = []
    a << super
    a += [:update_vehicle_usage_metrics, :update_operations_metrics,:update_storage_method]
    a.flatten
  end

  # Forces an update of an assets usage metrics. This performs an update on the record.
  def update_vehicle_usage_metrics(save_asset = true)

    Rails.logger.info "Updating the recorded vehicle usage metrics for asset = #{object_key}"
    # nothing to do for now

  end

  # Forces an update of an assets operations metrics. This performs an update on the record.
  def update_operations_metrics(save_asset = true)

    Rails.logger.info "Updating the recorded operations metrics for asset = #{object_key}"
    # nothing to do for now

  end


  # Forces an update of an assets storage method. This performs an update on the record.
  def update_storage_method(save_asset = true)

    Rails.logger.info "Updating the recorded storage method for asset = #{object_key}"

    unless new_record?
      if storage_method_updates.empty?
        self.vehicle_storage_method_type = nil
      else
        event = storage_method_updates.last
        self.vehicle_storage_method_type = event.vehicle_storage_method_type
      end
      save if save_asset
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def update_service_life typed_asset
    super

    #TODO might need to update this for used miles.
    typed_asset.expected_useful_miles = policy_analyzer.get_min_service_life_miles

  end

  # Set the description field
  def set_description
    self.description = "#{self.manufacturer.code} #{self.manufacturer_model}" unless self.manufacturer.nil?
  end

  # Set resonable defaults for a new rolling stock asset
  def set_defaults
    super
  end

end
