qc = QueryCategory.find_by(name: 'Identification & Classification')

# create vin db view
vin_view_sql = <<-SQL
  CREATE OR REPLACE VIEW service_vehicle_vin_view AS
    select transam_assets.id as transam_asset_id, serial_numbers.identification as vin from serial_numbers
    inner join transam_assets 
    on transam_assets.id = serial_numbers.identifiable_id and serial_numbers.identifiable_type = 'TransamAsset'
    inner join transit_assets
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    inner join service_vehicles
    on transit_assets.transit_assetible_id = service_vehicles.id and transit_assets.transit_assetible_type = 'ServiceVehicle'
SQL

ActiveRecord::Base.connection.execute vin_view_sql

vin_data_table = QueryAssetClass.find_or_create_by(
  table_name: 'service_vehicle_vin_view', 
  transam_assets_join: "LEFT JOIN service_vehicle_vin_view on service_vehicle_vin_view.transam_asset_id = transam_assets.id"
)

# query field
vin_qf = QueryField.find_or_create_by(
  name: 'vin',
  label: 'Vehicle Identification Number (VIN)',
  filter_type: 'text',
  query_category: qc
)
vin_qf.query_asset_classes = [vin_data_table]

# create Iventory ID  db view
view_sql = <<-SQL
  CREATE OR REPLACE VIEW serial_identification_view AS
    select transam_assets.id as transam_asset_id, serial_numbers.identification as serial_identification from serial_numbers
    inner join transam_assets 
    on transam_assets.id = serial_numbers.identifiable_id and serial_numbers.identifiable_type = 'TransamAsset'
    inner join transit_assets
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    where transit_assets.fta_asset_class_id IN 
    (SELECT fta_asset_classes.id FROM fta_asset_classes WHERE fta_asset_classes.class_name = 'CapitalEquipment')
SQL

ActiveRecord::Base.connection.execute view_sql

data_table = QueryAssetClass.find_or_create_by(
  table_name: 'serial_identification_view', 
  transam_assets_join: "LEFT JOIN serial_identification_view on serial_identification_view.transam_asset_id = transam_assets.id"
)

# query field
qf = QueryField.find_or_create_by(
  name: 'serial_identification',
  label: 'Serial # / Inventory ID #',
  filter_type: 'text',
  query_category: qc
)
qf.query_asset_classes = [data_table]
