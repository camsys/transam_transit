class MoveBuildingOwnershipOrganizationAssetTransamAssets < ActiveRecord::DataMigration
  def up
    Facility.joins(:transit_asset).joins('INNER JOIN assets ON assets.id = transit_assets.id').where.not(assets: {building_ownership_organization_id: nil}).where(facilities: {facility_ownership_organization_id: nil}).each do |facility|
      facility.update_columns(facility_ownership_organization_id: facility.asset.building_ownership_organization_id)
    end
  end
end