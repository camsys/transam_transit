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
        infrastructure_operation_method_type: infrastructure_operation_method_type.try(:api_json, options),
        infrastructure_control_system_type: infrastructure_control_system_type.try(:api_json, options)
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
      :segment_type,
      :location,
      :service_status,
      :last_life_cycle_action,
      :life_cycle_action_date
  ]

  def rowify fields=nil, snapshot_date=nil
    super (fields || DEFAULT_FIELDS), snapshot_date
  end
end
