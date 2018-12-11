#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class A90TemplateBuilder < TemplateBuilder

  include TransamFormatHelper

  attr_accessor :ntd_report

  SHEET_NAME = "A-90"

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    idx = 5
    sheet.add_row
    sheet.add_row
    sheet.add_row ['1. Revenue Vehicles - Percent of revenue vehicles that have met or exceeded their useful life benchmark'] + ['']*5
    sheet.merge_cells "A#{idx-2}:F#{idx-2}"
    sheet.add_row subheader_row

    FtaVehicleType.active.each do |fta_vehicle_type|
      ntd_performance_measure = NtdPerformanceMeasure.find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Revenue Vehicles'), asset_level: "#{fta_vehicle_type.code} - #{fta_vehicle_type.name}")

      sheet.add_row ["#{fta_vehicle_type.code} - #{fta_vehicle_type.name}", ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=C#{idx}-B#{idx}", nil, ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

    idx += 3
    sheet.add_row
    sheet.add_row ['2. Service Vehicles - Percent of service vehicles that have met or exceeded their useful life benchmark'] + ['']*5
    sheet.merge_cells "A#{idx-2}:F#{idx-2}"
    sheet.add_row subheader_row
    FtaSupportVehicleType.active.each do |fta_vehicle_type|
      ntd_performance_measure = NtdPerformanceMeasure.find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Equipment'), asset_level: fta_vehicle_type.name)

      sheet.add_row [fta_vehicle_type.name, ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=C#{idx}-B#{idx}", nil, ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

    idx += 3
    fta_asset_category = FtaAssetCategory.find_by(name: 'Facilities')
    sheet.add_row
    sheet.add_row ['3. Facility - Percent of facilities rated 3 or below on the condition scale'] + ['']*5
    sheet.merge_cells "A#{idx-2}:F#{idx-2}"
    sheet.add_row subheader_row
    FtaAssetClass.where(fta_asset_category: fta_asset_category).active.each do |fta_class|
      ntd_performance_measure = NtdPerformanceMeasure.find_by(fta_asset_category: fta_asset_category, asset_level: fta_class.name)

      sheet.add_row [fta_class.name, ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=C#{idx}-B#{idx}", nil, ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

    idx += 3
    sheet.add_row
    sheet.add_row ['4. Infrastructure - Percent of track segments with performance restrictions'] + ['']*5
    sheet.merge_cells "A#{idx-2}:F#{idx-2}"
    sheet.add_row subheader_row
    FtaModeType.active.each do |fta_mode_type|
      ntd_performance_measure = NtdPerformanceMeasure.find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Infrastructure'), asset_level: fta_mode_type.to_s)

      sheet.add_row [fta_mode_type.to_s, ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=C#{idx}-B#{idx}", nil, ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

  end

  # header rows
  def subheader_row
    ['Performance Measure',	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year)} Target (%)",	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year)} Performance (%)",	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year)} Difference",	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year+1)} Target (%)",	'N/A']
  end

  def column_styles
    styles = [
    ]
    styles
  end

  def row_styles
    styles = []
    idx = 2
    styles << {:name => 'gray', :row => idx}

    idx += 1
    styles << {:name => 'lt-gray', :row => idx}

    idx += FtaVehicleType.active.count + 2
    styles << {:name => 'gray', :row => idx}
    idx += 1
    styles << {:name => 'lt-gray', :row => idx}

    idx += FtaSupportVehicleType.active.count + 2
    styles << {:name => 'gray', :row => idx}
    idx += 1
    styles << {:name => 'lt-gray', :row => idx}

    idx += FtaAssetClass.where(fta_asset_category: FtaAssetCategory.find_by(name: 'Facilities')).active.count + 2
    styles << {:name => 'gray', :row => idx}
    idx += 1
    styles << {:name => 'lt-gray', :row => idx}

  end

  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super
    a << {name: 'lt-gray', bg_color: "A9A9A9", b: true}
    a << {name: 'gray', bg_color: "808080", alignment: { horizontal: :center}, b: true}
    a.flatten
  end

  def worksheet_name
    SHEET_NAME
  end

  private

  def initialize(*args)
    super
  end

end
