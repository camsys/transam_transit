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
  attr_accessor :is_group_report

  SHEET_NAME = "A-90"

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    idx = 2
    sheet.add_row subheader_row

    ## Rolling Stock Section
    section_number = 1 
    section_name = 'Rolling Stock - Percent of revenue vehicles that have met or exceeded their useful life benchmark'
    FtaVehicleType.active.each do |fta_vehicle_type|
      ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Revenue Vehicles'), asset_level: "#{fta_vehicle_type.code} - #{fta_vehicle_type.name}")

      puts ntd_performance_measure.inspect

      sheet.add_row [section_number, section_name, "#{fta_vehicle_type.code} - #{fta_vehicle_type.name}", ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=E#{idx}-D#{idx}", ntd_performance_measure.try(:future_pcnt_goal), ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

    ## Equipment Section
    section_number = 2
    section_name = 'Equipment - Percent of service vehicles that have met or exceeded their useful life benchmark'
    FtaSupportVehicleType.active.each do |fta_vehicle_type|
      ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Equipment'), asset_level: fta_vehicle_type.name)

      sheet.add_row [section_number, section_name, fta_vehicle_type.name, ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=E#{idx}-D#{idx}", ntd_performance_measure.try(:future_pcnt_goal), ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

    ## Facilities Section
    section_number = 3
    fta_asset_category = FtaAssetCategory.find_by(name: 'Facilities')
    section_name =  'Facility - Percent of facilities rated below 3 on the condition scale'
    groups = [
                {
                  name: 'Passenger / Parking Facilities', 
                  codes: ['passenger_facility', 'parking_facility']
                },
                {
                  name: 'Administrative / Maintenance Facilities', 
                  codes: ['admin_facility', 'maintenance_facility']
                }
              ]
    groups.each do |group| 
      pcnt_goal_sum = nil
      pcnt_performance_sum = nil
      future_pcnt_goal_sum = nil
      na = nil 
      count = 0

      FtaAssetClass.where(fta_asset_category: fta_asset_category, code: group[:codes]).active.each do |fta_class|
        ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: fta_asset_category, asset_level: fta_class.name)
        if ntd_performance_measure
          pcnt_goal_sum = pcnt_goal_sum.to_f + ntd_performance_measure.try(:pcnt_goal).to_f
          pcnt_performance_sum = pcnt_performance_sum.to_f + ntd_performance_measure.try(:pcnt_performance).to_f
          future_pcnt_goal_sum = future_pcnt_goal_sum.to_f + ntd_performance_measure.try(:future_pcnt_goal).to_f
          na = "N/A"
          count += 1
        end
      end
        sheet.add_row [section_number, section_name, group[:name], count > 0 ? pcnt_goal_sum/count : nil, count > 0 ? pcnt_performance_sum/count : nil, "=E#{idx}-D#{idx}", count > 0 ? future_pcnt_goal_sum/count : nil, na]
        idx += 1
    end

    ## Infrastructure Section
    section_number = 4
    section_name = "Infrastructure - Percent of track segments with performance restrictions"
    FtaModeType.active.each do |fta_mode_type|
      ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Infrastructure'), asset_level: fta_mode_type.to_s)

      sheet.add_row [section_number, section_name, fta_mode_type.to_s, ntd_performance_measure.try(:pcnt_goal), ntd_performance_measure.try(:pcnt_performance), "=E#{idx}-D#{idx}", ntd_performance_measure.try(:future_pcnt_goal), ntd_performance_measure ? nil : 'N/A']
      idx += 1
    end

  end

  # header rows
  def subheader_row
    ['Section Number', 'Section Name', 'Performance Measure',	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year)} Target (%)",	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year)} Performance (%)",	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year)} Difference",	"#{format_as_fiscal_year(@ntd_report.ntd_form.fy_year+1)} Target (%)",	'N/A']
  end

  def column_styles
    styles = [
    ]
    styles
  end

  def row_styles
    styles = []
    idx = 0
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
    self.is_group_report = self.is_group_report.nil? ? false : true
  end

end
