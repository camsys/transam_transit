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
        ['Org', get_fiscal_year_label, 'Category','Class','Type','Sub Type','Count', 'Book Value', 'Replacement Cost']
      when 'data'
        data = []
        @assets.group('organizations.short_name','fta_asset_categories.name','fta_asset_classes.name','COALESCE(fta_vehicle_types.name, fta_equipment_types.name, fta_support_vehicle_types.name, fta_facility_types.name, fta_track_types.name, fta_guideway_types.name, fta_power_signal_types.name)', 'asset_subtypes.name').count.each do |k,v|
          row = [k[0]]
          row << format_as_fiscal_year(fy)
          row << k[1]
          row << k[2]
          row << k[3]
          row << k[4]
          row << v
          row << @assets.where('fta_vehicle_types.name = ? OR fta_equipment_types.name = ? OR fta_support_vehicle_types.name = ? OR fta_facility_types.name = ? OR fta_track_types.name = ? OR fta_guideway_types.name = ? OR fta_power_signal_types.name = ?', k[3], k[3], k[3], k[3], k[3], k[3], k[3]).where(asset_subtypes: {name: k[4]}).sum{ |a| a.book_value.to_i }
          row << @assets.where('fta_vehicle_types.name = ? OR fta_equipment_types.name = ? OR fta_support_vehicle_types.name = ? OR fta_facility_types.name = ? OR fta_track_types.name = ? OR fta_guideway_types.name = ? OR fta_power_signal_types.name = ?', k[3], k[3], k[3], k[3], k[3], k[3], k[3]).where(asset_subtypes: {name: k[4]}).sum{ |a| a.scheduled_replacement_cost.to_i }
          data << row
        end

        data
      when 'formats'
        [nil, nil, nil, nil, nil,nil,nil, :currency, :currency]
      else
        []
    end
  end
end
