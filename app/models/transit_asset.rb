#------------------------------------------------------------------------------
#
# TransitAsset
#
# Base class of all transit assets. This class is used to track properties that
# are common to all transit assets such as tracking how the asset was purchased
# etc.
#
#------------------------------------------------------------------------------
class TransitAsset < Asset

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize    :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { districts.clear }

  #------------------------------------------------------------------------------
  # Associations common to all transit assets
  #------------------------------------------------------------------------------

  # each asset uses a funding type
  belongs_to  :fta_funding_type

  # each asset was puchased using one or more grants
  has_many    :grants,  :through => :grant_purchases

  # each asset was puchased using one or more grants
  has_many    :grant_purchases,  :foreign_key => :asset_id, :dependent => :destroy

  # each transit asset has zero or more maintenance provider updates. .
  has_many    :maintenance_provider_updates, -> {where :asset_event_type_id => MaintenanceProviderUpdateEvent.asset_event_type.id }, :class_name => "MaintenanceProviderUpdateEvent",  :foreign_key => :asset_id

  # Each asset can be associated with 0 or more districts
  has_and_belongs_to_many   :districts,  :foreign_key => :asset_id

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates   :fta_funding_type,  :presence => :true

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  SEARCHABLE_FIELDS = [
  ]
  CLEANSABLE_FIELDS = [
  ]

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :fta_funding_type_id
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def searchable_fields
    a = []
    a << super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  # Forces an update of an assets maintenance provider. This performs an update on the record.
  def update_maintenance_provider

    Rails.logger.info "Updating the recorded maintenance provider for asset = #{object_key}"

    unless new_record?
      unless maintenance_provider_updates.empty?
        event = maintenance_provider_updates.last
        self.maintenance_provider_type = event.maintenance_provider_type
        save
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new rolling stock asset
  def set_defaults
    super
  end

end
