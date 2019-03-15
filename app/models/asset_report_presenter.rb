class AssetReportPresenter
  attr_accessor :assets
  attr_accessor :fy

  include TransamFormatHelper
  include FiscalYearHelper
  
  def organization_ids
    if assets.blank?
      []
    else
      assets.distinct.pluck('transam_assets.organization_id')
    end
  end

  # Convert to a hash, keyed by org
  def assets_by_organization
    org_hash = Hash.new

    Organization.where(id: @assets.pluck('transam_assets.organization_id')).each do |org|
      org_hash[org] = @assets.where(organization_id: org.id)
    end

    @assets_by_organization ||= org_hash
  end

  def[](index)
    case index.to_s
      when 'labels'
        ['Org', get_fiscal_year_label, 'Type','Sub Type','Count', 'Book Value', 'Replacement Cost']
      when 'data'
        data = []
        assets_by_organization.each do |org, assets|
          org_assets = assets.joins('INNER JOIN organizations ON organizations.id = transam_assets.organization_id').joins('INNER JOIN asset_subtypes ON asset_subtypes.id = transam_assets.asset_subtype_id').joins('INNER JOIN asset_types ON asset_types.id = asset_subtypes.asset_type_id')
          org_assets.group('organizations.short_name', 'asset_types.name', 'asset_subtypes.name').each do |k,v|
            row = [k[0]]
            row << format_as_fiscal_year(fy)
            row << k[1]
            row << k[2]
            row << v
            row << org_assets.where(asset_subtypes: {name: k[2]}).sum{ |a| a.book_value.to_i }
            row << org_assets.where(asset_subtypes: {name: k[2]}).sum{ |a| a.scheduled_replacement_cost.to_i }
            data << row
          end
        end

        data
      when 'formats'
        [nil, nil, nil, nil, nil, :currency, :currency]
      else
        []
    end
  end
end
