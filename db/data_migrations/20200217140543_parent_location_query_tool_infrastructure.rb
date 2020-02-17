class ParentLocationQueryToolInfrastructure < ActiveRecord::DataMigration
  def up
    location_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW location_transam_assets_view AS
      SELECT transam_assets.organization_id, transam_assets.id AS location_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS location_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility' 
WHERE transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)
    SQL
    ActiveRecord::Base.connection.execute location_transam_assets_view_sql

    parent_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW parent_transam_assets_view AS
SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS parent_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id != 4)
UNION
SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, NULL, transam_assets.description,
CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), description) AS parent_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id = 4)
    SQL
    ActiveRecord::Base.connection.execute parent_transam_assets_view_sql


    infrastructures_object_key_view_sql = <<-SQL
    CREATE OR REPLACE VIEW infrastructures_object_key_view AS
    SELECT DISTINCT infrastructures.id AS id, transam_assets.object_key AS object_key FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
    SQL

    parent_id_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW parent_id_transam_assets_view AS
      SELECT transam_assets.id AS id, parents.object_key AS parent_object_key
      FROM transam_assets
      INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
      INNER JOIN transam_assets AS parents ON parents.id = transam_assets.parent_id
      WHERE fta_asset_category_id != 4
      UNION
      SELECT transam_assets.id AS id, parents.object_key AS parent_object_key
      FROM transam_assets
      INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
      INNER JOIN infrastructures_object_key_view AS parents ON parents.id = transam_assets.parent_id
      WHERE fta_asset_category_id = 4
    SQL
    ActiveRecord::Base.connection.execute infrastructures_object_key_view_sql
    ActiveRecord::Base.connection.execute parent_id_transam_assets_view_sql

    location_qac = QueryAssociationClass.find_or_create_by(table_name: 'location_transam_assets_view', id_field_name: 'location_id', display_field_name: 'location_name')
    QueryField.find_by(name: 'location_id').update!(query_association_class: location_qac)

    parent_qf = QueryField.find_by(name: 'parent_id')
    parent_qf.update!(name: 'parent_object_key')
    parent_qc = QueryAssetClass.find_or_create_by(table_name: 'parent_id_transam_assets_view', transam_assets_join: 'LEFT JOIN parent_id_transam_assets_view ON parent_id_transam_assets_view.id = transam_assets.id')
    parent_qf.query_asset_classes = [parent_qc]

  end
end