class Track < Infrastructure
  belongs_to :infrastructure_track

  belongs_to :infrastructure_gauge_type
  belongs_to :infrastructure_reference_rail

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :infrastructure_track_id, presence: true
  validates :max_permissible_speed, presence: true, numericality: { greater_than: 0 }
  validates :max_permissible_speed_unit, presence: true
end
