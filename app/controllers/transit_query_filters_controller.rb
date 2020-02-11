class TransitQueryFiltersController < QueryFiltersController
  def vehicle_rebuild_types
    asset_events = AssetEvent.where(id: AssetEvent.where(asset_event_type: AssetEventType.find_by(class_name: 'RehabilitationUpdateEvent')).group(:base_transam_asset_id).pluck(Arel.sql("max(asset_events.id)")))
    lookup_table_data = VehicleRebuildType.all.pluck(:id, :name).map{|d| {id: d[0], name: d[1]}}

    idx = 0 # indicate other
    others = asset_events.where.not(other_vehicle_rebuild_type: [nil, ""]).pluck(:other_vehicle_rebuild_type).uniq.map{|name|
      idx -= 1
      {id: idx, name: name}
    }

    render json: (lookup_table_data + others)
  end
end