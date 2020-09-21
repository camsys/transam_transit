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

      na = ntd_performance_measure ? "No" : 'Yes'
      pcnt_goal = (na == "No") ? ntd_performance_measure.try(:pcnt_goal) : "N/A"
      #pcnt_goal = (na == "No") ? 5000 : "N/A"
      difference = (na == "No") ? "=E#{idx}-D#{idx}" : nil 

      sheet.add_row [section_number, section_name, "#{fta_vehicle_type.code} - #{fta_vehicle_type.name}", pcnt_goal, ntd_performance_measure.try(:pcnt_performance), difference, ntd_performance_measure.try(:future_pcnt_goal), na]
      idx += 1
    end

    ## Equipment Section
    section_number = 2
    section_name = 'Equipment - Percent of service vehicles that have met or exceeded their useful life benchmark'
    FtaSupportVehicleType.active.each do |fta_vehicle_type|
      ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Equipment'), asset_level: fta_vehicle_type.name)

      na = ntd_performance_measure ? "No" : 'Yes'
      pcnt_goal = (na == "No") ? ntd_performance_measure.try(:pcnt_goal) : "N/A"
      difference = (na == "No") ? "=E#{idx}-D#{idx}" : nil 

      sheet.add_row [section_number, section_name, fta_vehicle_type.name, pcnt_goal, ntd_performance_measure.try(:pcnt_performance), difference, ntd_performance_measure.try(:future_pcnt_goal), na]
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
      na = "Yes" 
      count = 0
      FtaAssetClass.where(fta_asset_category: fta_asset_category, code: group[:codes]).active.each do |fta_class|
        asset_level = "#{fta_class.code} - #{fta_class.name}"
        ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: fta_asset_category, asset_level: asset_level)
        if ntd_performance_measure
          pcnt_goal_sum = pcnt_goal_sum.to_f + ntd_performance_measure.try(:pcnt_goal).to_f
          pcnt_performance_sum = pcnt_performance_sum.to_f + ntd_performance_measure.try(:pcnt_performance).to_f
          future_pcnt_goal_sum = future_pcnt_goal_sum.to_f + ntd_performance_measure.try(:future_pcnt_goal).to_f
          na = "No"
          count += 1

        end
      end

        pcnt_goal = (na == "No") ? pcnt_goal_sum : "N/A"
        difference = (na == "No") ? "=E#{idx}-D#{idx}" : nil 

        sheet.add_row [section_number, section_name, group[:name], pcnt_goal, count > 0 ? (pcnt_performance_sum/count).round(2) : nil, difference, count > 0 ? (future_pcnt_goal_sum/count).round(2) : nil, na]
        idx += 1
    end

    ## Infrastructure Section
    section_number = 4
    section_name = "Infrastructure - Percent of track segments with performance restrictions"
    FtaModeType.active.each do |fta_mode_type|
      ntd_performance_measure = @ntd_report.ntd_performance_measures.where(is_group_measure: @is_group_report).find_by(fta_asset_category: FtaAssetCategory.find_by(name: 'Infrastructure'), asset_level: fta_mode_type.to_s)

      na = ntd_performance_measure ? "No" : 'Yes'
      pcnt_goal = (na == "No") ? ntd_performance_measure.try(:pcnt_goal) : "N/A"
      difference = (na == "No") ? "=E#{idx}-D#{idx}" : nil 

      sheet.add_row [section_number, section_name, fta_mode_type.to_s, pcnt_goal, ntd_performance_measure.try(:pcnt_performance), difference, ntd_performance_measure.try(:future_pcnt_goal), na]
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
