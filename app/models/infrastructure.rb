class Infrastructure < TransamAssetRecord

  after_initialize :set_defaults

  acts_as :transit_asset, as: :transit_assetible

  belongs_to :infrastructure_segment_unit_type
  belongs_to :infrastructure_chain_type
  belongs_to :infrastructure_segment_type
  belongs_to :infrastructure_division
  belongs_to :infrastructure_subdivision

  belongs_to :land_ownership_organization, class_name: 'Organization'
  belongs_to :shared_capital_responsibility_organization, class_name: 'Organization'

  has_many    :infrastructure_components,  :class_name => 'InfrastructureComponent', :foreign_key => :parent_id, :dependent => :nullify, :inverse_of => :parent
  accepts_nested_attributes_for :infrastructure_components, :reject_if => :all_blank, :allow_destroy => true

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of service types into primary and secondary.
  has_one :primary_assets_fta_service_type, -> { is_primary },
          class_name: 'AssetsFtaServiceType', :foreign_key => :transam_asset_id
  has_one :primary_fta_service_type, through: :primary_assets_fta_service_type, source: :fta_service_type



  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :description, presence: true
  validates :infrastructure_segment_unit_type_id, presence: true
  validates :from_line, presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :from_segment, presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long'}
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
      :track_gradient_pcnt,
      :track_gradient_degree,
      :track_gradient,
      :track_gradient_unit,
      :horizontal_alignment,
      :horizontal_alignment_unit,
      :vertical_alignment,
      :vertical_alignment_unit,
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
      :other_land_ownership_organization_id,
      :shared_capital_responsibility_organization_id,
      :primary_fta_mode_type_id,
      :primary_fta_service_type_id,
      :latitude,
      :longitude
  ]

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

  protected

  def set_defaults
    self.purchase_cost = infrastructure_components.pluck('transam_assets.purchase_cost').sum
    self.purchase_date = infrastructure_components.order('transam_assets.purchase_date').first.try(:purchase_date) || Date.today
    self.purchased_new = !(infrastructure_components.pluck(:purchased_new).include? false)
    self.in_service_date = self.purchase_date
    self.manufacture_year = self.purchase_date.year
  end
end
