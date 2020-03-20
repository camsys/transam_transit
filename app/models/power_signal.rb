class PowerSignal < Infrastructure
  belongs_to :infrastructure_operation_method_type
  belongs_to :infrastructure_control_system_type

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'PowerSignal')) }

  FORM_PARAMS = [
      :location_name,
      :num_tracks,
      :infrastructure_operation_method_type_id,
      :infrastructure_control_system_type_id
  ]

  def api_json(options={})
    super.merge(
      {
        location_name: location_name,
        num_tracks: num_tracks,
        infrastructure_operation_method_type: infrastructure_operation_method_type.try(:api_json),
        infrastructure_control_system_type: infrastructure_control_system_type.try(:api_json)
      }
    )
  end
end
