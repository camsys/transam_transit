class AssetReportPresenter
  attr_accessor :assets
  attr_accessor :fy

  def organization_ids
    if assets.blank?
      []
    else
      assets.uniq.pluck(:organization_id)
    end
  end

  # Convert to a hash, keyed by org
  def assets_by_organization
    @assets_by_organization ||= @assets.includes(:organization).group_by(&:organization)
  end
end