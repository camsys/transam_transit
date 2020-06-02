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

  def self.get_lines
    lines = []

    self.distinct.pluck(:infrastructure_track_id).each do |infrastructure_track|
      self.distinct.where(infrastructure_track_id: infrastructure_track).pluck(:from_line).each do |line|
        lines << self.where(from_line: line, infrastructure_track_id: infrastructure_track).or(self.where(to_line: line, infrastructure_track_id: infrastructure_track))
      end
    end

    lines
  end

  def get_segmentable_with_like_line_attributes(include_self: false)
    if include_self
      Track.where(organization_id: organization_id, infrastructure_track_id: infrastructure_track_id, from_line: from_line).or(Track.where(organization_id: organization_id, infrastructure_track_id: infrastructure_track_id, to_line: to_line).where.not(to_line: nil))
    else
      Track.where(organization_id: organization_id, infrastructure_track_id: infrastructure_track_id, from_line: from_line).where.not(id: id).or(Track.where(organization_id: organization_id, infrastructure_track_id: infrastructure_track_id, to_line: to_line).where.not(id: id, to_line: nil))
    end
  end

  def linked_performance_restriction_updates
    PerformanceRestrictionUpdateEvent.where(transam_asset_id: self.get_segmentable_with_like_line_attributes.pluck(:id)).select{ |event|
      overlaps(event)
    }
  end

  def history
    AssetEvent.unscoped.where(id: linked_performance_restriction_updates.map{|x| x.id} + asset_events.pluck(:id)).order(updated_at: :desc)
  end

  def api_json(options={})
    super.merge(
      {
        infrastructure_track: infrastructure_track.try(:api_json, options),
        infrastructure_gauge_type: infrastructure_gauge_type.try(:api_json, options),
        infrastructure_reference_rail: infrastructure_reference_rail.try(:api_json, options),
        max_permissible_speed: max_permissible_speed,
        max_permissible_speed_unit: max_permissible_speed_unit,
        horizontal_alignment: horizontal_alignment,
        horizontal_alignment_unit: horizontal_alignment_unit,
        vertical_alignment: vertical_alignment,
        vertical_alignment_unit: vertical_alignment_unit
      }
    )
  end

  DEFAULT_FIELDS = [
      :asset_id,
      :org_name,
      :from_line,
      :from_segment,
      :to_line,
      :to_segment,
      :subtype,
      :description,
      :main_line, 
      :branch,
      :track,
      :segment_type,
      :location,
      :service_status,
      :last_life_cycle_action,
      :life_cycle_action_date
  ]

  def rowify fields=nil
    super fields || DEFAULT_FIELDS
  end

end
