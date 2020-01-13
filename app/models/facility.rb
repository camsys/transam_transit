class Facility < TransamAssetRecord

  acts_as :transit_asset, as: :transit_assetible

  before_destroy { fta_mode_types.clear }

  belongs_to :esl_category
  belongs_to :leed_certification_type
  belongs_to :facility_capacity_type

  # Each facility has a set (0 or more) of facility features
  has_and_belongs_to_many   :facility_features,    :foreign_key => :transam_asset_id,    :join_table => :assets_facility_features

  # Each facility has a set (0 or more) of fta mode type. This is the primary mode
  # serviced at the facility
  has_many                  :assets_fta_mode_types,       :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many                  :fta_mode_types,           :through => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :as => :transam_asset
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many :secondary_fta_mode_types, through: :secondary_assets_fta_mode_types, source: :fta_mode_type,    :join_table => :assets_fta_mode_types

  belongs_to :fta_private_mode_type

  belongs_to :land_ownership_organization, :class_name => "Organization"
  belongs_to :facility_ownership_organization, :class_name => "Organization"

  # each facility has zero or more operations update events
  has_many    :facility_operations_updates, -> {where :asset_event_type_id => FacilityOperationsUpdateEvent.asset_event_type.id }, :class_name => "FacilityOperationsUpdateEvent", :as => :transam_asset

  scope :ada_accessible, -> { where(ada_accessible: true) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :manufacture_year, presence: true

  validates :facility_name, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :esl_category_id, presence: true
  validates :facility_size, presence: true
  validates :facility_size_unit, presence: true
  validates :section_of_larger_facility, inclusion: { in: [ true, false ] }
  validates :ada_accessible, inclusion: { in: [ nil, true, false ] }
  validates :num_structures, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_floors, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_elevators, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_escalators, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_parking_spaces_public, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_parking_spaces_private, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :lot_size, numericality: { greater_than: 0 }, allow_nil: true
  validates :lot_size_unit, presence: true, if: :lot_size
  #validates :primary_fta_mode_type, presence: true

  validate :primary_and_secondary_cannot_match

  def primary_and_secondary_cannot_match
    if primary_fta_mode_type != nil 
      if (primary_fta_mode_type.in? secondary_fta_mode_types) 
        errors.add(:primary_fta_mode_type, "cannot also be a secondary mode")
      end
    end
  end

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  FORM_PARAMS = [
      :facility_name,
      :ntd_id,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :county,
      :country,
      :esl_category_id,
      :facility_capacity_type_id,
      :facility_size,
      :facility_size_unit,
      :section_of_larger_facility,
      :num_structures,
      :num_floors,
      :num_elevators,
      :nem_escalators,
      :num_parking_spaces_public,
      :num_parking_spaces_private,
      :lot_size,
      :lot_size_unit,
      :leed_certification_type_id,
      :ada_accessible,
      :fta_private_mode_type_id,
      :land_ownership_organization_id,
      :other_land_ownership_organization,
      :facility_ownership_organization_id,
      :other_facility_ownership_organization,
      :primary_fta_mode_type_id,
      :secondary_fta_mode_type_ids => [],
      :facility_feature_ids => []
  ]

  CLEANSABLE_FIELDS = [
      'facility_name',
      'address1',
      'address2',
      'city',
      'state',
      'zip',
      'county',
      'country'
  ]

  SEARCHABLE_FIELDS = [
      :facility_name,
      :address1,
      :address2,
      :city,
      :state,
      :zip
  ]
  def dup
    super.tap do |new_asset|
      new_asset.fta_mode_types = self.fta_mode_types
      new_asset.facility_features = self.facility_features
      new_asset.transit_asset = self.transit_asset.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.facility_ownership_organization = nil
    transferred_asset.land_ownership_organization = nil
    transferred_asset.other_facility_ownership_organization = nil
    transferred_asset.other_land_ownership_organization = nil
    transferred_asset.pcnt_capital_responsibility = nil
    transferred_asset.save(validate: false)

    return transferred_asset
  end

  def primary_fta_mode_type_id
    primary_fta_mode_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    build_primary_assets_fta_mode_type(fta_mode_type_id: num, is_primary: true)
  end

  def categorization
    TransitAsset::CATEGORIZATION_PRIMARY
  end

  def latlng
    if geometry
      return [geometry.y,geometry.x] 
    else
      return [nil,nil]
    end
  end

  protected

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method #{method}"
      Rails.logger.warn "You are calling the old asset for this method #{method}"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

end
