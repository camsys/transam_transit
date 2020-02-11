class AddFeaturesQueryTool < ActiveRecord::DataMigration
  def up
    # Features (Vehicle, Facility)
    # create the asset class view
    transit_asset_assets_features_view_sql = <<-SQL
      CREATE OR REPLACE VIEW transit_asset_assets_features_view AS
      SELECT transam_assets.id AS transam_asset_id, facility_features.code AS features_code
      FROM assets_facility_features
      INNER JOIN facility_features ON assets_facility_features.facility_feature_id = facility_features.id
      INNER JOIN facilities ON assets_facility_features.transam_asset_id = facilities.id
      INNER JOIN transit_assets ON transit_assetible_id = facilities.id AND transit_assetible_type = 'Facility'
      INNER JOIN transam_assets ON transam_assetible_id = transit_assets.id AND transam_assetible_type = 'TransitAsset'
      UNION ALL
      SELECT transam_assets.id AS transam_asset_id, vehicle_features.code
      FROM assets_vehicle_features
      INNER JOIN vehicle_features ON assets_vehicle_features.vehicle_feature_id = vehicle_features.id
      INNER JOIN revenue_vehicles ON assets_vehicle_features.transam_asset_id = revenue_vehicles.id
      INNER JOIN service_vehicles ON service_vehiclible_id = revenue_vehicles.id AND service_vehiclible_type = 'RevenueVehicle'
      INNER JOIN transit_assets ON transit_assetible_id = service_vehicles.id AND transit_assetible_type = 'ServiceVehicle'
      INNER JOIN transam_assets ON transam_assetible_id = transit_assets.id AND transam_assetible_type = 'TransitAsset'
    SQL
    ActiveRecord::Base.connection.execute transit_asset_assets_features_view_sql

    # create the association/seed view
    transit_asset_features_view_sql = <<-SQL
      CREATE OR REPLACE VIEW transit_asset_features_view AS
        SELECT 'Facility' AS `type`, `id`, `name`, `code`, `active` FROM facility_features
        UNION ALL SELECT 'RevenueVehicle' AS `type`, `id`, `name`, `code`, `active` FROM vehicle_features
    SQL
    ActiveRecord::Base.connection.execute transit_asset_features_view_sql

    features_table = QueryAssetClass.find_or_create_by(
        table_name: 'transit_asset_assets_features_view',
        transam_assets_join: "left join transit_asset_assets_features_view on transit_asset_assets_features_view.transam_asset_id = transam_assets.id"
    )
    features_association_table = QueryAssociationClass.find_or_create_by(table_name: 'transit_asset_features_view', display_field_name: 'name', id_field_name: 'code')
    features_field = QueryField.find_or_create_by(
        name: 'features_code',
        label: 'Features',
        query_category: QueryCategory.find_or_create_by(name: 'Operations'),
        filter_type: 'multi_select',
        query_association_class: features_association_table
    )
    features_field.query_asset_classes << [features_table]
  end
end