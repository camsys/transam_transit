# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------
#
#------------------------------------------------------------------------------
#
# Structure
#
# Abstract class that adds physical structure attributes to the base Asset class. All
# structure assets should be drived from this base class
#
#------------------------------------------------------------------------------
class Structure < Asset

  # Callbacks
  after_initialize  :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all structures
  #------------------------------------------------------------------------------

  # The land for each structure is owned
  belongs_to  :land_ownership_type,         :class_name => "FtaOwnershipType",  :foreign_key => :land_ownership_type_id
  belongs_to  :land_ownership_organization, :class_name => "Organization",      :foreign_key => :land_ownership_organization_id

  # The building for each structure is owned
  belongs_to  :building_ownership_type,         :class_name => "FtaOwnershipType",  :foreign_key => :building_ownership_type_id
  belongs_to  :building_ownership_organization, :class_name => "Organization",      :foreign_key => :building_ownership_organization_id

  # Each structure has a LEED certification
  belongs_to  :leed_certification_type

  # each facility has zero or more operations update events
  has_many    :facility_operations_updates, -> {where :asset_event_type_id => FacilityOperationsUpdateEvent.asset_event_type.id }, :class_name => "FacilityOperationsUpdateEvent", :foreign_key => "asset_id"

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates                 :description,                         :presence => true
  validates                 :address1,                            :presence => true
  validates                 :city,                                :presence => true
  validates                 :state,                               :presence => true
  validates                 :zip,                                 :presence => true
  validates                 :land_ownership_type_id,              :presence => true
  validates                 :building_ownership_type_id,          :presence => true
  validates                 :leed_certification_type_id,          :presence => true
  validates                 :num_floors,                          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
  validates                 :num_structures,                      :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
  validates                 :num_parking_spaces_public,           :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates                 :num_parking_spaces_private,          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates                 :lot_size,                            :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates                 :facility_size,                       :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates_inclusion_of    :section_of_larger_facility,          :in => [true, false]
  validates                 :pcnt_operational,                    :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :description,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :land_ownership_type_id,
      :building_ownership_type_id,
      :land_ownership_organization_id,
      :building_ownership_organization_id,
      :leed_certification_type_id,
      :num_floors,
      :num_structures,
      :num_parking_spaces_public,
      :num_parking_spaces_private,
      :lot_size,
      :line_number,
      :facility_size,
      :section_of_larger_facility,
      :pcnt_operational,
      :ada_accessible_ramp
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
      :street_address => self.address1,
      :city => self.city,
      :state => self.state,
      :zip => self.zip,
      :land_ownership_type_id => self.land_ownership_type.present? ? self.land_ownership_type.to_s : nil,
      :building_ownership_type_id => self.building_ownership_type.present? ? self.building_ownership_type.to_s : nil,
      :land_ownership_organization_id => self.land_ownership_organization.present? ? self.land_ownership_organization.to_s : nil,
      :building_ownership_organization_id => self.building_ownership_organization.present? ? self.building_ownership_organization.to_s : nil,
      :leed_certification_type_id => self.leed_certification_type.present? ? self.leed_certification_type.to_s : nil,
      :num_floors => self.num_floors,
      :num_structures => self.num_structures,
      :num_parking_spaces_public => self.num_parking_spaces_public,
      :num_parking_spaces_private => self.num_parking_spaces_private,
      :lot_size => self.lot_size,
      :line_number => self.line_number,
      :facility_size => self.facility_size,
      :section_of_larger_facility => self.section_of_larger_facility,
      :pcnt_operational => self.pcnt_operational,
      :ada_accessible_ramp => self.ada_accessible_ramp
    })
  end

  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def num_floors=(num)
    self[:num_floors] = sanitize_to_int(num)
  end
  def num_structures=(num)
    self[:num_structures] = sanitize_to_int(num)
  end
  def lot_size=(num)
    self[:lot_size] = sanitize_to_float(num)
  end
  def facility_size=(num)
    self[:facility_size] = sanitize_to_int(num)
  end
  def pcnt_operational=(num)
    self[:pcnt_operational] = sanitize_to_int(num)
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  # Override the name property
  def name
    description
  end

  # override the cost property
  def cost
    purchase_cost
  end

  def searchable_fields
    a = []
    a << super
    a += [
      :description,
      :address1,
      :address2,
      :city,
      :state,
      :zip
    ]
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    a += [
      'description',
      'address1',
      'address2',
      'pcnt_operational'
    ]
    a.flatten
  end

  def update_methods
    a = []
    a << super
    a += [:update_facility_operations_metrics]
    a.flatten
  end

  # Forces an update of a facility's operations metrics. This performs an update on the record.
  def update_facility_operations_metrics(save_asset = true)

    Rails.logger.info "Updating the recorded facility operations metrics for asset = #{object_key}"
    # nothing to do for now

  end

  def transfer new_organization_id
    org = Organization.where(:id => new_organization_id).first

    transferred_asset = self.copy false
    transferred_asset.object_key = nil

    transferred_asset.disposition_date = nil
    transferred_asset.building_ownership_type = nil
    transferred_asset.building_ownership_organization = nil
    transferred_asset.fta_funding_type = nil
    transferred_asset.fta_ownership_type = FtaOwnershipType.find_by(:name => 'Unknown')
    transferred_asset.in_service_date = nil
    transferred_asset.land_ownership_type = nil
    transferred_asset.organization = org
    transferred_asset.pcnt_capital_responsibility = nil
    transferred_asset.pcnt_operational = nil
    transferred_asset.purchase_cost = nil
    transferred_asset.purchase_date = nil
    transferred_asset.purchased_new = false
    transferred_asset.service_status_type = nil
    transferred_asset.title_owner_organization_id = nil

    transferred_asset.generate_object_key(:object_key)
    transferred_asset.asset_tag = transferred_asset.object_key

    transferred_asset.save(:validate => false)

    return transferred_asset
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def clean_habtm_relationships
    fta_service_types.clear
  end

  # Set resonable defaults for a new generic structure
  def set_defaults
    super

    self.manufacture_year ||= SystemConfig.instance.time_epoch.year
    self.purchase_date ||= SystemConfig.instance.time_epoch
    self.leed_certification_type ||= LeedCertificationType.find_by_name("Not Certified")
    self.num_parking_spaces_public ||= 0
    self.num_parking_spaces_private ||= 0
    self.num_floors ||= 1
    self.num_structures ||= 1
    self.state ||= SystemConfig.instance.default_state_code
  end

end
