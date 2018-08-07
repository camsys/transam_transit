class Infrastructure < TransamAssetRecord

  acts_as :transit_asset, as: :transit_assetible

  belongs_to :infrastructure_segment_type
  belongs_to :infrastructure_chain_type
  belongs_to :infrastructure_division
  belongs_to :infrastructure_subdivision
  belongs_to :infrastructure_track
  belongs_to :infrastructure_gauge_type
  belongs_to :infrastructure_reference_rail
  belongs_to :land_ownership_organization, class_name: 'Organization'
  belongs_to :shared_capital_responsibility_organization, class_name: 'Organization'

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of mode types into primary and secondary.
  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id,    :join_table => :assets_fta_service_types
  has_many :secondary_fta_mode_types, through: :secondary_assets_fta_mode_types, source: :fta_mode_type,    :join_table => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :secondary_assets_fta_mode_type, -> { is_not_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id
  has_one :secondary_fta_mode_type, through: :secondary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of service types into primary and secondary.
  has_one :secondary_assets_fta_service_type, -> { is_not_primary },
          class_name: 'AssetsFtaServiceType', :foreign_key => :transam_asset_id
  has_one :secondary_fta_service_type, through: :secondary_assets_fta_service_type, source: :fta_service_type



  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :description, presence: true
  validates :infrastructure_segment_type_id, presence: true
  validates :from_line, presence: true, if: Proc.new{|a| a.infrastructure_segment_type.name != 'Lat / Long'}
  validates :to_line, presence: true, if: Proc.new{|a| a.infrastructure_segment_type.name != 'Lat / Long'}
  validates :from_segment, presence: true, if: Proc.new{|a| a.infrastructure_segment_type.name != 'Lat / Long'}
  validates :to_segment, presence: true, if: Proc.new{|a| a.infrastructure_segment_type.name != 'Lat / Long'}
  validates :segment_unit, presence: true, if: Proc.new{|a| a.infrastructure_segment_type.name == 'Marker Posts'}
  validates :infrastructure_chain_type_id, presence: true, if: Proc.new{|a| a.infrastructure_segment_type.name == 'Chaining'}
  validates :standing_capacity, presence: true
  validates :infrastructure_division_id, presence: true
  validates :infrastructure_subdivision_id, presence: true
  validates :infrastructure_track_id, presence: true
  validates :full_service_speed, presence: true, numericality: { greater_than: 0 }
  validates :full_service_speed_unit, presence: true

end
