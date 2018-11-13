class Track < Infrastructure

  include TransamSegmentable

  belongs_to :infrastructure_track

  belongs_to :infrastructure_gauge_type
  belongs_to :infrastructure_reference_rail

  has_many   :performance_restriction_updates,      -> {where :asset_event_type_id => PerformanceRestrictionUpdateEvent.asset_event_type.id }, :class_name => "PerformanceRestrictionUpdateEvent",  :as => :transam_asset

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

  def self.get_segmentable_with_like_line_attributes(instance, include_self: false)
    if include_self
      Track.where(organization_id: instance.organization_id, infrastructure_track_id: instance.infrastructure_track_id, from_line: instance.from_line).or(Track.where(organization_id: instance.organization_id, infrastructure_track_id: instance.infrastructure_track_id, to_line: instance.to_line).where.not(to_line: nil))
    else
      Track.where(organization_id: instance.organization_id, infrastructure_track_id: instance.infrastructure_track_id, from_line: instance.from_line).where.not(id: instance.id).or(Track.where(organization_id: instance.organization_id, infrastructure_track_id: instance.infrastructure_track_id, to_line: instance.to_line).where.not(id: instance.id, to_line: nil))
    end
  end

  def linked_performance_restriction_updates
    PerformanceRestrictionUpdateEvent.where(transam_asset_id: Track.get_segmentable_with_like_line_attributes(self).pluck(:id)).select{ |event|
      overlaps(event)
    }
  end

  def history
    AssetEvent.where(id: linked_performance_restriction_updates.map{|x| x.id} + asset_events(true).pluck(:id)).order('event_date DESC, created_at DESC')
  end



end
