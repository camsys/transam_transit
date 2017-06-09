class AssetReportPresenter
  attr_accessor :assets
  attr_accessor :fy

  include TransamFormatHelper

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

  def[](index)
    case index.to_s
      when 'labels'
        ['Org', 'Fiscal Year','Type','Sub Type','Count', 'Book Value', 'Replacement Cost']
      when 'data'
        data = []
        assets_by_organization.each do |org, assets|
          assets.group_by(&:asset_subtype).each do |subtype, assets_by_subtype|
            row = [org.short_name]
            row << format_as_fiscal_year(fy)
            row << subtype.asset_type.to_s
            row << subtype.to_s
            row << assets_by_subtype.count
            row << assets_by_subtype.sum{ |a| a.book_value.to_i }
            row << assets_by_subtype.sum{ |a| a.estimated_replacement_cost.to_i }
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
