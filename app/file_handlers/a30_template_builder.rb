#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class A30TemplateBuilder < TemplateBuilder

  attr_accessor :ntd_report

  @manufacturers_end_column = nil
  @vehicle_types_end_column = nil
  @years_end_column = nil
  @fuel_types_end_column = nil
  @dual_fuel_types_end_column = nil
  @ownership_types_end_column = nil
  @funding_types_end_column = nil
  @additional_mode_tos_end_column = nil

  SHEET_NAME = "A-30"

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    #facilities = @ntd_report.ntd_facilities
    #support_vehicles = @ntd_report.ntd_service_vehicle_fleets
    rev_vehicles = @ntd_report.ntd_revenue_vehicle_fleets


    row_count = rev_vehicles.count

    #(0..row_count - 1).each do |idx|
    rev_vehicles.each do |rev_vehicle|
      row_data = []
      if rev_vehicle
        row_data << rev_vehicle.rvi_id
        row_data << rev_vehicle.agency_fleet_id
        row_data << rev_vehicle.vehicle_type
        row_data << rev_vehicle.size
        row_data << rev_vehicle.num_active
        row_data << (rev_vehicle.dedicated ? 'Yes' : 'No')
        row_data << (rev_vehicle.direct_capital_responsibility ? 'Yes' : 'No')
        row_data << rev_vehicle.manufacture_code
        row_data << rev_vehicle.other_manufacturer
        row_data << rev_vehicle.model_number
        row_data << rev_vehicle.manufacture_year
        row_data << rev_vehicle.rebuilt_year
        row_data << rev_vehicle.fuel_type
        row_data << "NEED TO ADD OTHER FUEL TYPE"
        row_data << rev_vehicle.dual_fuel_type
        row_data << rev_vehicle.vehicle_length
        row_data << rev_vehicle.seating_capacity
        row_data << rev_vehicle.standing_capacity
        row_data << rev_vehicle.ownership_type
        row_data << "NEED TO ADD OTHER OWNERSHIP TYPE"
        row_data << rev_vehicle.funding_type
        row_data << rev_vehicle.num_ada_accessible
        row_data << "#{rev_vehicle.additional_fta_mode} #{rev_vehicle.additional_fta_service_type}"
        row_data << rev_vehicle.num_emergency_contingency
        row_data << rev_vehicle.useful_life_benchmark
        row_data << rev_vehicle.useful_life_remaining
        row_data << rev_vehicle.total_active_miles_in_period
        row_data << rev_vehicle.avg_lifetime_active_miles
        row_data << rev_vehicle.status
        row_data << rev_vehicle.notes
        row_data << "NEED TO ADD DELETE COLUMN"
      else
        row_data << ['']*28
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

    # Manufacturers (Row 2)
    manufacturers = Manufacturer.active.where(filter: "SupportVehicle")
    @manufacturers_end_column = alphabet[manufacturers.count]
    sheet.add_row make_row(manufacturers)

    #Vehicle Types (Row 3)
    vehicle_types = FtaVehicleType.active.all
    @vehicle_types_end_column = alphabet[vehicle_types.count]
    sheet.add_row make_row(vehicle_types)

    #Years (Row 4)
    years = (1800..Time.now.year).to_a.reverse
    @years_end_column = alphabet[years.count]
    sheet.add_row make_row(years)

    #Fuel types (Row 5)
    fuel_types = FuelType.active
    @fuel_types_end_column = alphabet[fuel_types.count]
    sheet.add_row make_row(fuel_types)

    #Dual Fuel types (Row 6)
    dual_fuel_types = DualFuelType.active
    @dual_fuel_types_end_column = alphabet[dual_fuel_types.count]
    sheet.add_row make_row(dual_fuel_types)

    #Ownership Types (Row 7)
    ownership_types = FtaOwnershipType.active
    @ownership_types_end_column = alphabet[ownership_types.count]
    sheet.add_row make_row(ownership_types)

    #Funding Types (Row 8)
    funding_types = FtaFundingType.active
    @funding_types_end_column = alphabet[funding_types.count]
    sheet.add_row make_row(funding_types)

    #Additional mode/tos (Row 9)
    modes = FtaModeType.active
    toss = FtaModeType.active 
    mode_tos = []
    modes.each do |mode|
      toss.each do |tos|
        mode_tos << "#{mode.code} #{tos.code}"
      end
    end
    @additional_mode_tos_end_column = alphabet[mode_tos.count]
    sheet.add_row mode_tos 

    # Active/Retired (Row 10)
    row = []
    booleans = ["Active", "Retired"]
    sheet.add_row make_row(booleans)

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
    sheet.add_data_validation("F3:F1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

    #No Capital Replacement Responsibility
    sheet.add_data_validation("G3:G1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

    #Manufacturers
    sheet.add_data_validation("H3:H1000",
    {
        type: :list,
        formula1: "lists!$A$2:$#{@manufacturers_end_column}$2"
    })

    #Vehicle Types
    sheet.add_data_validation("C3:C1000",
    {
        type: :list,
        formula1: "lists!$A$3:$#{@vehicle_types_end_column}$3"
    })

    #Year Manufactured
    sheet.add_data_validation("K3:K1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@years_end_column}$4"
    })

    #Year rebuilt
    sheet.add_data_validation("L3:L1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@years_end_column}$4"
    })

    #Fuel Type
    sheet.add_data_validation("M3:M1000",
    {
        type: :list,
        formula1: "lists!$A$5:$#{@fuel_types_end_column}$5"
    })

    #Dual Fuel Type
    sheet.add_data_validation("O3:O1000",
    {
        type: :list,
        formula1: "lists!$A$6:$#{@fuel_types_end_column}$6"
    })

    #Ownership Type
    sheet.add_data_validation("S3:S1000",
    {
        type: :list,
        formula1: "lists!$A$7:$#{@ownership_types_end_column}$7"
    })

    #Funding Type
    sheet.add_data_validation("U3:U1000",
    {
        type: :list,
        formula1: "lists!$A$8:$#{@funding_types_end_column}$8"
    })

    #Additional MODE/TOS
    sheet.add_data_validation("W3:W1000",
    {
        type: :list,
        formula1: "lists!$A$9:$#{@additional_mode_tos_end_column}$9"
    })

    #Active Inactive
    sheet.add_data_validation("AC3:AC1000",
    {
        type: :list,
        formula1: "lists!$A$10:$B$10"
    })


    # Dedicated Fleet
    sheet.add_data_validation("AE3:AE1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

  end

  # header rows
  def header_rows
    title_row = ['']*62

    detail_row = [
      'RVI ID',
      'Agency Fleet Id',
      'Vehicle Type',
      'Total Vehicles',
      'Active Vehicles',
      'Dedicated Fleet',
      'No Capital Replacement Responsibility',
      'Manufacturer',
      'Describe Other Manufacturer',
      'Model',
      'Year Manufactured',
      'Year Rebuilt',
      'Fuel Type',
      'Other Fuel Type',
      'Dual Fuel Type',
      'Vehicle Length',
      'Seating Capacity',
      'Standing Capacity',
      'Ownership Type',
      'Other Ownership Type',
      'Funding Type',
      'ADA Accessible Vehicles',
      'Supports Another Mode/TOS',
      'Emergency Contingency Vehicles',
      'Useful Life Benchmark',
      'Useful Life Remaining',
      'Miles This Year',
      'Avg Lifetime Miles per Active Vehicle',
      'Status',
      'Notes',
      'Delete'
    ]

    [title_row, detail_row]
  end

  def column_styles
    styles = [
      {:name => 'gray', :column => 8},
      {:name => 'gray', :column => 13},
      {:name => 'gray', :column => 14},
      {:name => 'gray', :column => 19},
      {:name => 'gray', :column => 25}
    ]
    styles
  end

  def row_styles
    styles = [
      {:name => 'lt-gray', :row => 2}
    ]
    styles
  end

  def row_types
    []
    types
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