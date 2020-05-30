class Infrastructure < TransamAssetRecord

  SHARED_CAPITAL_RESPONSIBILITY_NA = 0

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


  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------
  # TODO: Make this a shareable Module 
  
  def rowify
    fields = {
              asset_tag_drilldown: "Asset Id", 
              org_name: "Organization",
              from_line: "Line (from)",
              from_segment: "From",
              to_line: "Line (to)",
              to_segment: "To",
              subtype_name: "Subtype",
              description: "Description",
              infrastructure_division: "Main Line / Division",
              infrastructure_subdivision: "Branch / Subivision",
              infrastructure_track: "Track",
              infrastructure_segment_type: "Segment Type",
              relative_location: "Location",
              service_status_name: "Service Status",
              last_life_cycle_action: "Last Life Cycle Action",
              life_cycle_action_date: "Life Cycle Action Date"
            }
    
    user_row = {}
    fields.each do |key,value|
      user_row[value] =  self.send(key).to_s
    end
    return user_row 
  end

  def org_name
    organization.try(:short_name)
  end

  def subtype_name
    asset_subtype.try(:name)
  end

  def service_status_name
    service_status.try(:service_status_type).try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

  def last_life_cycle_action
    history.first.try(:asset_event_type).try(:name)
  end

  def life_cycle_action_date
    history.first.try(:event_date)
  end


  def asset_tag_drilldown
    #drilldown link
    #TODO: use user path instead of hard coded html
    "<a href='/inventory/#{self.object_key}/'>#{self.asset_tag}</a>"
  end

  protected

  def set_defaults
    self.purchase_cost ||= 0
    self.purchase_date ||= Date.today
    self.purchased_new = self.purchased_new.nil? ? true : self.purchased_new
    self.in_service_date ||= self.purchase_date
  end

  def update_infrastructure_component_values
    original = TransitAsset.find_by(id: transit_asset.id)

    if original && (original.asset_subtype_id != asset_subtype_id || original.fta_type_id != fta_type_id)
      infrastructure_components.each{|x| x.update(fta_type_id: fta_type_id, asset_subtype_id: asset_subtype_id)}
    end
  end
end
