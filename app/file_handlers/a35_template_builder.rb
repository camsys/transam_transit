#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class A35TemplateBuilder < TemplateBuilder

  attr_accessor :ntd_report

  @vehicle_types_end_column = nil
  @modes_end_column = nil
  @years_end_column = nil

  SHEET_NAME = "A-35"

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    support_vehicles = @ntd_report.ntd_service_vehicle_fleets
    row_count = support_vehicles.count

    #(0..row_count - 1).each do |idx|
    support_vehicles.each do |vehicle|
      row_data = []
      if vehicle
        row_data << vehicle.sv_id  #A
        row_data << vehicle.agency_fleet_id #B
        row_data << vehicle.fleet_name  #C
        row_data << vehicle.vehicle_type #D
        row_data << vehicle.primary_fta_mode_type #E
        row_data << vehicle.manufacture_year #F
        row_data << vehicle.estimated_cost #G
        row_data << vehicle.useful_life_benchmark
        row_data << vehicle.useful_life_remaining
        row_data << vehicle.size
        row_data << vehicle.pcnt_capital_responsibility
        row_data << vehicle.estimated_cost_year
        row_data << vehicle.secondary_fta_mode_types
        row_data << vehicle.notes
        row_data << vehicle.status
        row_data << ""
      else
        row_data << ['']*14
      end
      row_data << ''
      sheet.add_row row_data.flatten.map{|x| x.to_s}
    end


  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)
    
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    alphabet = ('A'..'ZZZ').to_a

    # Basic Booleans (Row 1)
    row = []
    booleans= ["Yes", "No"]
    sheet.add_row make_row(booleans)

    # vehicle types (Row 2)
    vehicle_types = FtaSupportVehicleType.active
    @vehicle_types_end_column = alphabet[vehicle_types.count]
    sheet.add_row make_row(vehicle_types)

    # Modes (Row 3)
    modes = FtaModeType.active
    @modes_end_column = alphabet[modes.count]
    sheet.add_row make_row(modes)

    #Years (Row 4)
    years = (1800..Time.now.year).to_a.reverse
    @years_end_column = alphabet[years.count]
    sheet.add_row make_row(years)

  end

  def make_row objects
    row = []
    objects.each do |object|
      row << object.to_s 
    end
    return row
  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    #sheet.sheet_protection

    # Dedicated Fleet
    sheet.add_data_validation("D3:D1000",
    {
        type: :list,
        formula1: "lists!$A$2:$#{@vehicle_types_end_column}$2"
    })

    # Modes
    sheet.add_data_validation("E3:E1000",
    {
        type: :list,
        formula1: "lists!$A$3:$#{@modes_end_column}$3"
    })

    # Years
    sheet.add_data_validation("F3:F1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@years_end_column}$4"
    })


    # Years
    sheet.add_data_validation("L3:L1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@years_end_column}$4"
    })

    # Delete
    sheet.add_data_validation("P3:P1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })
  end

  # header rows
  def header_rows
    detail_row = [
      'ID', #A
      'Agency Fleet Id', #B
      'Fleet Name', #C
      'Vehicle Type', #D
      'Primary Mode', #E
      'Year Manufactured', #F
      'Estimated Cost', #G
      'Useful Life Benchmark (Years)', #H
      'Useful Life Remaining (Years)', #I
      'Total Vehicles', #J
      'Transit Agency Capital Responsibility (%)', #K
      'Year Dollars of Estimated Cost', #L
      'Secondary Modes(s)', #M
      'Notes', #N
      'Status', #O
      'Delete' #P
    ]

    [detail_row]
  end

  def column_styles
    styles = [
    ]
    styles
  end

  def row_styles
    styles = [
      {:name => 'lt-gray', :row => 0}
    ]
    styles
  end

  def row_types
    [:string]*15
  end

  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super
    # Header Styles
    a << {name: 'lt-gray', bg_color: "A9A9A9"}
    a << { name: 'gray', bg_color: "808080"}
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
