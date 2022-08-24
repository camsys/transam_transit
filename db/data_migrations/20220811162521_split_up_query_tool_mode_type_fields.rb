class SplitUpQueryToolModeTypeFields < ActiveRecord::DataMigration
  def up
    # pre-define shared attributes
    association_class = QueryAssociationClass.find_by(table_name: "fta_mode_types")
    query_category = QueryCategory.find_by(name: "Operations")
    field_name = "fta_mode_type_id"
    field_filter_type = "multi_select"

    # define new query_asset_classes
    query_asset_classes = [
      {
        table_name: "service_vehicle_assets_fta_mode_types_primary",
        transam_assets_join: "LEFT JOIN transit_assets as svpmta ON svpmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN service_vehicles as svpmsv ON svpmsv.id = svpmta.transit_assetible_id AND svpmta.transit_assetible_type = 'ServiceVehicle' LEFT JOIN assets_fta_mode_types as service_vehicle_assets_fta_mode_types_primary ON svpmsv.id = service_vehicle_assets_fta_mode_types_primary.transam_asset_id and service_vehicle_assets_fta_mode_types_primary.transam_asset_type = 'ServiceVehicle' and service_vehicle_assets_fta_mode_types_primary.is_primary = true"
      },
      {
        table_name: "service_vehicle_assets_fta_mode_types_secondary",
        transam_assets_join: "LEFT JOIN transit_assets as svsmta ON svsmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN service_vehicles as svsmsv ON svsmsv.id = svsmta.transit_assetible_id AND svsmta.transit_assetible_type = 'ServiceVehicle' LEFT JOIN assets_fta_mode_types as service_vehicle_assets_fta_mode_types_secondary ON svsmsv.id = service_vehicle_assets_fta_mode_types_secondary.transam_asset_id and service_vehicle_assets_fta_mode_types_secondary.transam_asset_type = 'ServiceVehicle' and service_vehicle_assets_fta_mode_types_secondary.is_primary = false"
      },
      {
        table_name: "revenue_vehicle_assets_fta_mode_types_primary",
        transam_assets_join: "LEFT JOIN transit_assets as rvpmta ON rvpmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN service_vehicles as rvpmsv ON rvpmsv.id = rvpmta.transit_assetible_id AND rvpmta.transit_assetible_type = 'ServiceVehicle' LEFT JOIN revenue_vehicles as rvpmrv on rvpmrv.id = rvpmsv.service_vehiclible_id and rvpmsv.service_vehiclible_type = 'RevenueVehicle' LEFT JOIN assets_fta_mode_types as revenue_vehicle_assets_fta_mode_types_primary ON rvpmrv.id = revenue_vehicle_assets_fta_mode_types_primary.transam_asset_id and revenue_vehicle_assets_fta_mode_types_primary.transam_asset_type = 'RevenueVehicle' and revenue_vehicle_assets_fta_mode_types_primary.is_primary = true"
      },
      {
        table_name: "revenue_vehicle_assets_fta_mode_types_secondary",
        transam_assets_join: "LEFT JOIN transit_assets as rvsmta ON rvsmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN service_vehicles as rvsmsv ON rvsmsv.id = rvsmta.transit_assetible_id AND rvsmta.transit_assetible_type = 'ServiceVehicle' LEFT JOIN revenue_vehicles as rvsmrv on rvsmrv.id = rvsmsv.service_vehiclible_id and rvsmsv.service_vehiclible_type = 'RevenueVehicle' LEFT JOIN assets_fta_mode_types as revenue_vehicle_assets_fta_mode_types_secondary ON rvsmrv.id = revenue_vehicle_assets_fta_mode_types_secondary.transam_asset_id and revenue_vehicle_assets_fta_mode_types_secondary.transam_asset_type = 'RevenueVehicle' and revenue_vehicle_assets_fta_mode_types_secondary.is_primary = false"
      },
      {
        table_name: "facility_assets_fta_mode_types_primary",
        transam_assets_join: "LEFT JOIN transit_assets as fpmta ON fpmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN facilities as fpmf ON fpmf.id = fpmta.transit_assetible_id AND fpmta.transit_assetible_type = 'Facility' LEFT JOIN assets_fta_mode_types as facility_assets_fta_mode_types_primary ON fpmf.id = facility_assets_fta_mode_types_primary.transam_asset_id and facility_assets_fta_mode_types_primary.transam_asset_type = 'Facility' and facility_assets_fta_mode_types_primary.is_primary = true"
      },
      {
        table_name: "facility_assets_fta_mode_types_secondary",
        transam_assets_join: "LEFT JOIN transit_assets as fsmta ON fsmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN facilities as fsmf ON fsmf.id = fsmta.transit_assetible_id AND fsmta.transit_assetible_type = 'Facility' LEFT JOIN assets_fta_mode_types as facility_assets_fta_mode_types_secondary ON fsmf.id = facility_assets_fta_mode_types_secondary.transam_asset_id and facility_assets_fta_mode_types_secondary.transam_asset_type = 'Facility' and facility_assets_fta_mode_types_secondary.is_primary = false"
      },
      {
        table_name: "infrastructure_assets_fta_mode_types_primary",
        transam_assets_join: "LEFT JOIN transit_assets as ipmta ON ipmta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' left join infrastructures as ipmi ON ipmta.transit_assetible_id = ipmi.id and ipmta.transit_assetible_type = 'Infrastructure' LEFT JOIN assets_fta_mode_types as infrastructure_assets_fta_mode_types_primary ON ipmi.id = infrastructure_assets_fta_mode_types_primary.transam_asset_id and infrastructure_assets_fta_mode_types_primary.transam_asset_type = 'Infrastructure' and infrastructure_assets_fta_mode_types_primary.is_primary = true"
      },
      {
        table_name: "infrastructure_assets_fta_mode_types_secondary",
        transam_assets_join: "LEFT JOIN transit_assets as ismta ON ismta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' left join infrastructures as ismi ON ismta.transit_assetible_id = ismi.id and ismta.transit_assetible_type = 'Infrastructure' LEFT JOIN assets_fta_mode_types as infrastructure_assets_fta_mode_types_secondary ON ismi.id = infrastructure_assets_fta_mode_types_secondary.transam_asset_id and infrastructure_assets_fta_mode_types_secondary.transam_asset_type = 'Infrastructure' and infrastructure_assets_fta_mode_types_secondary.is_primary = false"
      }
    ]

    # define new query fields
    query_field_labels = [
      "Primary Mode (Service Vehicle)",
      "Secondary Mode(s) (Service Vehicle)",
      "Primary Mode (Revenue Vehicle)",
      "Supports Another Mode (Revenue Vehicle)",
      "Primary Mode (Facility)",
      "Secondary Mode(s) (Facility)",
      "Primary Mode (Infrastructure)",
      "Secondary Mode(s) (Infrastructure)"
    ]

    ActiveRecord::Base.transaction do
      # create the query asset classes
      query_asset_classes.each do |qac_attributes|
        QueryAssetClass.find_or_create_by(qac_attributes)
      end

      # create the query fields
      query_field_labels.each do |label|
        QueryField.find_or_create_by(name: field_name, label: label, query_category: query_category, filter_type: field_filter_type, query_association_class: association_class)
      end

      # join the fields with the asset classes
      query_asset_classes.each_with_index do |asset_class, i|
        QueryFieldAssetClass.find_or_create_by(query_field: QueryField.find_by(label: query_field_labels[i]), query_asset_class: QueryAssetClass.find_by(table_name: asset_class[:table_name]))
      end

      # cleanup old query fields/asset classes and associated saved queries
      ## define old fields
      old_primary_field = QueryField.find_by(label: "Primary Mode")
      old_secondary_field = QueryField.find_by(label: "Supports Another Mode")
      old_primary_class = QueryAssetClass.find_by(table_name: "assets_fta_mode_types_primary")
      old_secondary_class = QueryAssetClass.find_by(table_name: "assets_fta_mode_types_support")

      ## modify saved queries to remove old fields from output
      saved_query_fields = SavedQueryField.where(query_field_id: [old_primary_field.id, old_secondary_field.id])

      saved_query_fields.each do |sqf|
        sqf.saved_query.ordered_output_field_ids -= [old_primary_field.id, old_secondary_field.id]
        sqf.saved_query.save
      end

      ## remove associations
      saved_query_fields.destroy_all

      ## destroy old fields and asset classes
      old_primary_field.destroy
      old_secondary_field.destroy
      old_primary_class.destroy
      old_secondary_class.destroy
    end
  end
end