class Guideway < Infrastructure
  belongs_to :infrastructure_bridge_type
  belongs_to :infrastructure_crossing

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'Guideway')) }

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

  def api_json(options={})
    super.merge(
      {
        location_name: location_name,
        num_tracks: num_tracks,
        infrastructure_bridge_type: infrastructure_bridge_type.try(:api_json),
        num_spans: num_spans,
        num_decks: num_decks,
        infrastructure_crossing: infrastructure_crossing.try(:api_json),
        length: length,
        length_unit: length_unit,
        height: height,
        height_unit: height_unit,
        width: width,
        width_unit: width_unit,
        nearest_city: nearest_city,
        nearest_state: nearest_state
      }
    )
  end
end
