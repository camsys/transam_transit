class Track < Infrastructure

  include TransamSegmentable

  belongs_to :infrastructure_track

  belongs_to :infrastructure_gauge_type
  belongs_to :infrastructure_reference_rail

  has_many   :performance_restriction_updates,      -> {where :asset_event_type_id => PerformanceRestrictionUpdateEvent.asset_event_type.id }, :class_name => "PerformanceRestrictionUpdateEvent",  :foreign_key => :transam_asset_id

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'Track')) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :infrastructure_track_id, presence: true
  validates :max_permissible_speed, presence: true, numericality: { greater_than: 0 }
  validates :max_permissible_speed_unit, presence: true

  FORM_PARAMS = [
      :horizontal_alignment,
      :horizontal_alignment_unit,
      :vertical_alignment,
      :vertical_alignment_unit
  ]

  def linked_performance_restriction_updates
    PerformanceRestrictionUpdateEvent.where(transam_asset_id: Track.where(organization_id: self.organization_id).where.not(id: self.id).ids).select{ |event|
      overlaps(event)
    }
  end

  def history
    AssetEvent.where(id: linked_performance_restriction_updates.map{|x| x.id} + asset_events(true).pluck(:id)).order('event_date DESC, created_at DESC')
  end



end
