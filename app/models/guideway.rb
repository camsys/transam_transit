class Guideway < Infrastructure
  belongs_to :infrastructure_bridge_type
  belongs_to :infrastructure_crossing

  FORM_PARAMS = [
      :location_name,
      :num_tracks,
      :infrastructure_bridge_type_id,
      :num_spans,
      :num_decks,
      :infrastructure_crossing_id,
      :length,
      :length_unit,
      :height,
      :height_unit,
      :width,
      :width_unit,
      :nearest_city,
      :nearest_state
  ]
end
