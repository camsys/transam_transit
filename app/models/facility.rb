class Facility < TransamAssetRecord
  acts_as :transit_asset, as: :transit_assetible

  before_destroy { fta_mode_types.clear }

  belongs_to :esl_category
  belongs_to :leed_certification_type
  belongs_to :facility_capacity_type

  # Each facility has a set (0 or more) of facility features
  has_and_belongs_to_many   :facility_features,    :foreign_key => 'transit_asset_id',    :join_table => :assets_facility_features

  # Each facility has a set (0 or more) of fta mode type. This is the primary mode
  # serviced at the facility
  has_many                  :assets_fta_mode_types,       :foreign_key => :transit_asset_id,    :join_table => :assets_fta_mode_types
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :transit_asset_id,    :join_table => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transit_asset_id
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :foreign_key => :transit_asset_id,    :join_table => :assets_fta_mode_types
  has_many :secondary_fta_mode_types, through: :secondary_assets_fta_mode_types, source: :fta_mode_type,    :join_table => :assets_fta_mode_types

  belongs_to :fta_private_mode_type

  belongs_to :land_ownership_organization, :class_name => "Organization"
  belongs_to :facility_ownership_organization, :class_name => "Organization"

  # each facility has zero or more operations update events
  has_many    :facility_operations_updates, -> {where :asset_event_type_id => FacilityOperationsUpdateEvent.asset_event_type.id }, :class_name => "FacilityOperationsUpdateEvent", :foreign_key => :transam_asset_id

  scope :ada_accessible, -> { where(ada_accessible: true) }

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
      :num_public_parking,
      :num_private_parking,
      :lot_size,
      :lot_size_unit,
      :leed_certification_type_id,
      :ada_accessible,
      :fta_private_mode_type_id,
      :land_ownership_organization_id,
      :other_land_ownership_organization,
      :facility_ownership_organization_id,
      :other_facility_ownership_organization
  ]

  def primary_fta_mode_type_id
    primary_fta_mode_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    build_primary_assets_fta_mode_type(fta_mode_type_id: num, is_primary: true)
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
