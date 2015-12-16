class AnnualAssetAuditResultsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list)
    labels = ["Org", "Asset Type", 'Total', "Passed", "Failed"]
    data = []
    Rails.logger.debug "Org Ids = #{organization_id_list}"

    activity = Activity.find_by(:name => 'Annual Asset Audit')
    
    organization_id_list.each do |org_id|
      org = Organization.find(org_id)
      Rails.logger.debug "Summarizing for #{org.short_name}"
      org.asset_type_counts.each do |asset_type_id, count|
        if count > 0
          asset_type = AssetType.find(asset_type_id)
          asset_ids = Asset.operational.where("organization_id = ? and asset_type_id = ?", org.id, asset_type_id).pluck(:id)
          total = asset_ids.count
          failed = Audit.where('activity_id = ? AND audit_status_type_id = ? AND auditable_id IN (?)', activity.id, 3, asset_ids).count
          data << [org.short_name, asset_type.name, total, (total - failed), failed]
        end
      end
    end
    return [labels, data]
  end

end
