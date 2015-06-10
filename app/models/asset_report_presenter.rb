class AssetReportPresenter
  attr_accessor :assets
  attr_accessor :fy

  def organization_ids
    if assets.blank?
      []
    else
      assets.pluck(:organization_id).uniq
    end
  end

  # Convert to a hash, keyed by org
  def assets_by_organization
    @assets_by_organization ||= @assets.includes(:organization).group_by(&:organization)
  end
end
