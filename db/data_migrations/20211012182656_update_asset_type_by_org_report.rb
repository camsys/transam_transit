class UpdateAssetTypeByOrgReport < ActiveRecord::DataMigration
  def up
    # use transam_assets table
    Report.find_by(name: "Asset Type by Org Report")&.update(custom_sql:
     "SELECT c.short_name AS 'Org', b.name AS 'Type', COUNT(*) AS 'Count'
      FROM transam_assets a LEFT JOIN asset_subtypes b ON a.asset_subtype_id = b.id
      LEFT JOIN organizations c ON a.organization_id = c.id
      GROUP BY a.organization_id, a.asset_subtype_id ORDER BY c.short_name, b.name")
  end

  def down
    #use assets table
    Report.find_by(name: "Asset Type by Org Report")&.update(custom_sql:
      "SELECT c.short_name AS 'Org', b.name AS 'Type', COUNT(*) AS 'Count'
      FROM assets a LEFT JOIN asset_subtypes b ON a.asset_subtype_id = b.id
      LEFT JOIN organizations c ON a.organization_id = c.id
      GROUP BY a.organization_id, a.asset_subtype_id ORDER BY c.short_name, b.name")
  end
end