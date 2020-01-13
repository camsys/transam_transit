class UpdateParentQueryToolView < ActiveRecord::DataMigration
  def up
    parent_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW parent_transam_assets_view AS
      SELECT transam_assets.id AS parent_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,''), IFNULL(description,'')) AS parent_name
FROM `facilities` 
INNER JOIN `transit_assets` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility' 
INNER JOIN `transam_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL)
    SQL
    ActiveRecord::Base.connection.execute parent_transam_assets_view_sql
  end
end