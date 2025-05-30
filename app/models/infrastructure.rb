class Infrastructure < TransamAssetRecord

  SHARED_CAPITAL_RESPONSIBILITY_NA = 0

  include TransamFormatHelper

  after_initialize :set_defaults
  before_update        :update_infrastructure_component_values

  acts_as :transit_asset, as: :transit_assetible

  belongs_to :infrastructure_segment_unit_type
  belongs_to :infrastructure_chain_type
  belongs_to :infrastructure_segment_type
  belongs_to :infrastructure_division
  belongs_to :infrastructure_subdivision

  belongs_to :land_ownership_organization, class_name: 'Organization'
  belongs_to :shared_capital_responsibility_organization, class_name: 'Organization'

  has_many    :infrastructure_components,  :class_name => 'InfrastructureComponent', :foreign_key => :parent_id, :dependent => :destroy, :inverse_of => :parent
  accepts_nested_attributes_for :infrastructure_components, :reject_if => :all_blank, :allow_destroy => true

  has_many                  :assets_fta_mode_types,       :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many                  :fta_mode_types,           :through => :assets_fta_mode_types

  has_many                  :assets_fta_service_types,       :as => :transam_asset,    :join_table => :assets_fta_service_types
  has_many                  :fta_service_types,           :through => :assets_fta_service_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :as => :transam_asset
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of service types into primary and secondary.
  has_one :primary_assets_fta_service_type, -> { is_primary },
          class_name: 'AssetsFtaServiceType', :as => :transam_asset
  has_one :primary_fta_service_type, through: :primary_assets_fta_service_type, source: :fta_service_type



  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :infrastructure_segment_unit_type_id, presence: true
  validates :from_line, presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :from_segment, presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :to_segment, presence: true, if: Proc.new{|a| a.to_line.present? }
  validates :to_segment, numericality: {greater_than_or_equal_to: :from_segment}, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long' && a.from_line == a.to_line}
  validates :segment_unit, presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name == 'Marker Posts'}
  validates :infrastructure_chain_type_id, presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name == 'Chaining'}
  validates :infrastructure_segment_type_id, presence: true
  validates :infrastructure_division_id, presence: true
  validates :infrastructure_subdivision_id, presence: true


  FORM_PARAMS = [
      :from_line,
      :to_line,
      :infrastructure_segment_unit_type_id,
      :from_segment,
      :to_segment,
      :segment_unit,
      :from_location_name,
      :to_location_name,
      :infrastructure_chain_type_id,
      :relative_location,
      :relative_location_unit,
      :relative_location_direction,
      :infrastructure_segment_type_id,
      :infrastructure_division_id,
      :infrastructure_subdivision_id,
      :infrastructure_track_id,
      :direction,
      :infrastructure_gauge_type_id,
      :gauge,
      :gauge_unit,
      :infrastructure_reference_rail_id,
      :track_gradient,
      :track_gradient_unit,
      :crosslevel,
      :crosslevel_unit,
      :warp_parameter,
      :warp_parameter_unit,
      :track_curvature,
      :track_curvature_unit,
      :track_curvature_degree,
      :cant,
      :cant_unit,
      :cant_gradient,
      :cant_gradient_unit,
      :max_permissible_speed,
      :max_permissible_speed_unit,
      :land_ownership_organization_id,
      :other_land_ownership_organization,
      :shared_capital_responsibility_organization_id,
      :other_shared_capital_responsibility,
      :primary_fta_mode_type_id,
      :primary_fta_service_type_id,
      :latitude,
      :longitude
  ]

  CLEANSABLE_FIELDS = [

  ]

  def self.shared_capital_responsibility(val)
    if val == SHARED_CAPITAL_RESPONSIBILITY_NA
      'N/A'
    else
      Organization.find_by(id: val)
    end
  end

  def allowable_params
    a = []
    a << super
    a << {infrastructure_components_attributes: InfrastructureComponent.new.allowable_params}

    a.flatten
  end

  def dup
    super.tap do |new_asset|
      new_asset.transit_asset = self.transit_asset.dup
      new_asset.assets_fta_mode_types = self.assets_fta_mode_types
      new_asset.assets_fta_service_types = self.assets_fta_service_types
    end
  end

  def primary_fta_mode_type_id
    primary_fta_mode_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    build_primary_assets_fta_mode_type(fta_mode_type_id: num, is_primary: true)
  end

  def primary_fta_service_type_id
    primary_fta_service_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_service_type_id=(num)
    build_primary_assets_fta_service_type(fta_service_type_id: num, is_primary: true)
  end

  # override transam asset association
  def dependents
    infrastructure_components.map{|x| x.transam_asset}
  end

  ######## API Serializer ##############
  def api_json(options={})
    transit_asset.api_json(options).merge(
    {
      from_line: from_line,
      to_line: to_line,
      infrastructure_segment_unit_type: infrastructure_segment_unit_type.try(:api_json, options),
      from_segment: from_segment,
      to_segment: to_segment,
      segment_unit: segment_unit,
      from_location_name: from_location_name,
      to_location_name: to_location_name,
      infrastructure_chain_type: infrastructure_chain_type.try(:api_json, options),
      relative_location: relative_location,
      relative_location_unit: relative_location_unit,
      relative_location_direction: relative_location_direction,
      infrastructure_segment_type: infrastructure_segment_type.try(:api_json, options),
      infrastructure_division: infrastructure_division.try(:api_json),
      infrastructure_subdivision: infrastructure_subdivision.try(:api_json, options),
      direction: direction,
      gauge: gauge,
      gauge_unit: gauge_unit,
      track_gradient: track_gradient,
      track_gradient_unit: track_gradient_unit,
      crosslevel: crosslevel,
      crosslevel_unit: crosslevel_unit,
      warp_parameter: warp_parameter,
      warp_parameter_unit: warp_parameter_unit,
      track_curvature: track_curvature,
      track_curvature_unit: track_curvature_unit,
      track_curvature_degree: track_curvature_degree,
      cant: cant,
      cant_unit: cant_unit,
      cant_gradient: cant_gradient,
      cant_gradient_unit: cant_gradient_unit,
      max_permissible_speed: max_permissible_speed,
      max_permissible_speed_unit: max_permissible_speed_unit,
      land_ownership_organization: land_ownership_organization.try(:api_json, options),
      other_land_ownership_organization: other_land_ownership_organization,
      shared_capital_responsibility_organization: shared_capital_responsibility_organization.try(:api_json, options),
      other_shared_capital_responsibility: other_shared_capital_responsibility,
      primary_fta_mode_type: primary_fta_mode_type.try(:as_json),
      primary_fta_service_type: primary_fta_service_type.try(:as_json),
      latitude: latitude,
      longitude: longitude
    })
  end

  def inventory_api_json
    transit_asset.inventory_api_json.merge(
    {
      "Condition^service_status": service_status_name,
    })
  end


  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------
  # TODO: Make this a shareable Module 

  def field_library key 
    
    fields =  {
      from_line: {label: "Line (from)", method: :from_line, url: nil},
      from_segment: {label: "From", method: :formatted_from_segment, url: nil},
      to_line: {label: "Line (to)", method: :to_line, url: nil},
      to_segment: {label: "To", method: :formatted_to_segment, url: nil},
      description: {label: "Description", method: :description, url: nil},
      main_line: {label: "Main Line / Division", method: :infrastructure_division_name, url: nil},
      branch: {label: "Branch / Subivision", method: :infrastructure_subdivision_name, url: nil},
      track: {label: "Track", method: :infrastructure_track_name, url: nil},
      segment_type: {label: "Segment Type", method: :infrastructure_segment_type_name, url: nil},
      service_status: {label: "Service Status", method: :service_status_name, url: nil},
      number_of_tracks: {label: "Number of Tracks", method: :num_tracks, url: nil},
      primary_mode: {label: "Primary Mode", method: :primary_fta_mode_type_name, url: nil},
    }

    if fields[key]
      return fields[key]
    else #If not in this list, it may be part of TransitAsset
      return self.acting_as.field_library key 
    end

  end
  
  def rowify fields=nil, snapshot_date=nil
    fields ||= DEFAULT_FIELDS

    row = {}
    fields.each do |field|
      field_data = field_library(field)
      if [:last_life_cycle_action, :life_cycle_action_date, :service_status, :term_condition].include? field
        field_data[:args] = [snapshot_date]
      end
      row[field] =  {label: field_data[:label], data: field_data[:args] ? self.send(field_data[:method], *field_data[:args]) : self.send(field_data[:method]), url: field_data[:url]}
    end
    return row 
  end

  def formatted_from_segment
    format_as_decimal from_segment
  end

  def formatted_to_segment
    format_as_decimal to_segment
  end

  def service_status_name snapshot_date=nil
    if snapshot_date
      service_status(snapshot_date).try(:service_status_type).try(:name)
    else
      service_status.try(:service_status_type).try(:name)
    end
  end

  def service_status snapshot_date=nil
    if snapshot_date
      service_status_updates.where("event_date <= '#{snapshot_date}'").order(:event_date).last
    else
      service_status_updates.order(:event_date).last
    end
  end

  def infrastructure_track_name
    infrastructure_track.to_s 
  end

  def infrastructure_division_name
    infrastructure_division.to_s 
  end

  def infrastructure_subdivision_name
    infrastructure_subdivision.to_s
  end

  def infrastructure_segment_type_name
    infrastructure_segment_type.to_s 
  end

  def primary_fta_mode_type_name
    primary_fta_mode_type.try(:name)
  end

  protected

  def set_defaults
    unless self.transam_asset.destroyed?
      self.purchase_cost ||= 0
      self.purchase_date ||= Date.today
      self.purchased_new = self.purchased_new.nil? ? true : self.purchased_new
      self.in_service_date ||= self.purchase_date
    end
  end

  def update_infrastructure_component_values
    original = TransitAsset.find_by(id: transit_asset.id)

    if original && (original.asset_subtype_id != asset_subtype_id || original.fta_type_id != fta_type_id)
      infrastructure_components.each{|x| x.update(fta_type_id: fta_type_id, asset_subtype_id: asset_subtype_id)}
    end
  end
end
