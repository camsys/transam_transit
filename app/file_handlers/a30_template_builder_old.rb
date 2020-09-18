#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class A30TemplateBuilderOld < TemplateBuilder

  attr_accessor :ntd_report

  @manufacturers_end_column = nil
  @vehicle_types_end_column = nil
  @years_end_column = nil
  @fuel_types_end_column = nil
  @dual_fuel_types_end_column = nil
  @ownership_types_end_column = nil
  @funding_types_end_column = nil
  #@mode_tos_end_column = nil
  @rebuilt_types_end_column = nil

  @has_rail_safety_features = false

  SHEET_NAME = "Fleet Data"
  COLUMN_COUNT = 31


  def build

    # Create a new workbook
    p = Axlsx::Package.new
    wb = p.workbook

    # Call back to setup any implementation specific options needed
    setup_workbook(wb)

    mode_tos_list = @ntd_report.ntd_revenue_vehicle_fleets.distinct.pluck(:fta_mode, :fta_service_type) 
    mode_tos_list.each do |mode_tos|

      # Add the worksheet
      sheet = wb.add_worksheet(:name => "#{mode_tos[0]} #{mode_tos[1]}")  

      # setup any styles and cache them for later
      style_cache = {}
      styles.each do |s|
        Rails.logger.debug s.inspect
        style = wb.styles.add_style(s)
        Rails.logger.debug style.inspect
        style_cache[s[:name]] = style
      end
      Rails.logger.debug style_cache.inspect
      # Add the header rows
      title = sheet.styles.add_style(:bg_color => "00A9A9A9", :sz=>12)
      header_rows.each do |header_row|
        sheet.add_row header_row, :style => title
      end

      # add the rows
      add_rows(sheet)

      # Add the column styles
      column_styles.each do |col_style|
        Rails.logger.debug col_style.inspect
        sheet.col_style col_style[:column], style_cache[col_style[:name]]
      end

      # Add the row styles
      row_styles.each do |row_style|
        Rails.logger.debug row_style.inspect
        sheet.row_style row_style[:row], style_cache[row_style[:name]]
      end

      # set column widths
      sheet.column_widths *column_widths

      # Perform any additional processing
      post_process(sheet)
    end

    energy_sheet = wb.add_worksheet :name => 'Energy Consumption'
    # Add the header row
    title = energy_sheet.styles.add_style(:bg_color => "00A9A9A9", :sz=>12)
    energy_sheet.add_row(['Energy Type',  'Amount',  'Other Description', 'Unit Of Measure'], :style => title)

    # Serialize the spreadsheet to the stream and return it
    p.to_stream()

  end

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)

    #facilities = @ntd_report.ntd_facilities
    #support_vehicles = @ntd_report.ntd_service_vehicle_fleets
    mode_tos = sheet.name.split(' ')
    rev_vehicles = @ntd_report.ntd_revenue_vehicle_fleets.where(fta_mode: mode_tos[0], fta_service_type: mode_tos[1])

    #row_count = rev_vehicles.count

    #(0..row_count - 1).each do |idx|
    rev_vehicles.each do |rev_vehicle|
      row_data = []
      if rev_vehicle
        row_data << rev_vehicle.rvi_id&.to_s
        row_data << rev_vehicle.agency_fleet_id&.to_s
        row_data << rev_vehicle.vehicle_type
        row_data << rev_vehicle.size&.to_s
        row_data << rev_vehicle.num_active&.to_s

        if rev_vehicle.fta_asset_class == 'Rail Cars'
          @has_rail_safety_features = true
          RailSafetyFeature.active.each do |feature|
            row_data << rev_vehicle.send("total_#{feature.name.parameterize(separator: '_')}")
          end
        else
          RailSafetyFeature.active.count.times do
            row_data << ''
          end
        end

        row_data << (rev_vehicle.dedicated ? 'Yes' : 'No')
        row_data << (rev_vehicle.direct_capital_responsibility ? '' : 'Yes')
        row_data << (rev_vehicle.is_autonomous ? 'Yes' : '')
        row_data << rev_vehicle.manufacture_code&.to_s
        row_data << rev_vehicle.other_manufacturer
        row_data << rev_vehicle.model_number&.to_s
        row_data << rev_vehicle.manufacture_year&.to_s
        row_data << rev_vehicle.rebuilt_year&.to_s
        row_data << rev_vehicle.fuel_type
        row_data << rev_vehicle.other_fuel_type
        row_data << rev_vehicle.dual_fuel_type
        row_data << rev_vehicle.vehicle_length&.to_s
        row_data << rev_vehicle.seating_capacity&.to_s
        row_data << rev_vehicle.standing_capacity&.to_s
        row_data << rev_vehicle.ownership_type
        row_data << rev_vehicle.other_ownership_type
        row_data << rev_vehicle.funding_type
        row_data << rev_vehicle.num_ada_accessible&.to_s
        row_data << rev_vehicle.num_emergency_contingency&.to_s
        row_data << rev_vehicle.rebuilt_type&.to_s
        row_data << rev_vehicle.useful_life_benchmark&.to_s
        row_data << rev_vehicle.useful_life_remaining&.to_s
        row_data << rev_vehicle.total_active_miles_in_period&.to_s
        row_data << rev_vehicle.avg_lifetime_active_miles&.to_s
        row_data << rev_vehicle.status
        row_data << rev_vehicle.notes
        row_data << ""
      else
        row_data << [''] * COLUMN_COUNT
      end
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
    vehicle_type_row = []
    vehicle_types.each do |vt|
      vehicle_type_row << "#{vt.name} (#{vt.code})"
    end
    sheet.add_row vehicle_type_row

    #Years (Row 4)
    years = (1800..Time.now.year).to_a.reverse
    @years_end_column = alphabet[years.count]
    sheet.add_row make_row(years)

    #Fuel types (Row 5)
    fuel_types = FuelType.active
    @fuel_types_end_column = alphabet[fuel_types.count]
    fuel_type_row = []
    fuel_types.each do |t|
      fuel_type_row << "#{t.name}"
    end
    sheet.add_row fuel_type_row

    #Dual Fuel types (Row 6)
    dual_fuel_types = DualFuelType.active
    @dual_fuel_types_end_column = alphabet[dual_fuel_types.count]
    sheet.add_row make_row(dual_fuel_types)

    #Ownership Types (Row 7)
    ownership_types = FtaOwnershipType.active
    @ownership_types_end_column = alphabet[ownership_types.count]
    ownership_type_row = []
    ownership_types.each do |t|
      ownership_type_row << "#{t.name} (#{t.code})"
    end
    sheet.add_row ownership_type_row

    #Funding Types (Row 8)
    funding_types = FtaFundingType.active
    @funding_types_end_column = alphabet[funding_types.count]
    funding_type_row = []
    funding_types.each do |t|
      funding_type_row << "#{t.name} (#{t.code})"
    end
    sheet.add_row funding_type_row

    ##mode/tos (Row 9)
    # modes = FtaModeType.active
    # toss = FtaServiceType.active 
    # mode_tos = []
    # modes.each do |mode|
    #   toss.each do |tos|
    #     mode_tos << "#{mode.code} #{tos.code}"
    #   end
    # end
    # @mode_tos_end_column = alphabet[mode_tos.count]
    # sheet.add_row mode_tos 

    # Active/Retired (Row 9)
    row = []
    booleans = ["Active", "Retired"]
    sheet.add_row make_row(booleans)

    # Vehicle Rebuild Type (Row 10)
    rebuilt_types = VehicleRebuildType.active
    @rebuilt_types_end_column = alphabet[rebuilt_types.count]
    rebuilt_type_row = []
    rebuilt_types.each do |t|
      rebuilt_type_row << "#{t.name}"
    end
    sheet.add_row rebuilt_type_row

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
    sheet.add_data_validation("J2:J1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

    #No Capital Replacement Responsibility
    sheet.add_data_validation("K2:K1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

    # is autonomous
    sheet.add_data_validation("L2:L1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

    #Manufacturers
    sheet.add_data_validation("M2:M1000",
    {
        type: :list,
        formula1: "lists!$A$2:$#{@manufacturers_end_column}$2"
    })

    #Vehicle Types
    sheet.add_data_validation("C2:C1000",
    {
        type: :list,
        formula1: "lists!$A$3:$#{@vehicle_types_end_column}$3"
    })

    #Year Manufactured
    sheet.add_data_validation("P2:P1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@years_end_column}$4"
    })

    #Year rebuilt
    sheet.add_data_validation("Q2:Q1000",
    {
        type: :list,
        formula1: "lists!$A$4:$#{@years_end_column}$4"
    })

    #Fuel Type
    sheet.add_data_validation("R2:R1000",
    {
        type: :list,
        formula1: "lists!$A$5:$#{@fuel_types_end_column}$5"
    })

    #Dual Fuel Type
    sheet.add_data_validation("T2:T1000",
    {
        type: :list,
        formula1: "lists!$A$6:$#{@fuel_types_end_column}$6"
    })

    #Ownership Type
    sheet.add_data_validation("X2:X1000",
    {
        type: :list,
        formula1: "lists!$A$7:$#{@ownership_types_end_column}$7"
    })

    #Funding Type
    sheet.add_data_validation("Z2:Z1000",
    {
        type: :list,
        formula1: "lists!$A$8:$#{@funding_types_end_column}$8"
    })

    ##Additional MODE/TOS
    # sheet.add_data_validation("W2:W1000",
    # {
    #     type: :list,
    #     formula1: "lists!$A$9:$#{@mode_tos_end_column}$9"
    # })

    #Active Inactive
    sheet.add_data_validation("AH2:AH1000",
    {
        type: :list,
        formula1: "lists!$A$9:$B$9"
    })

    #Rebuilt Type
    sheet.add_data_validation("AC2:AC1000",
    {
        type: :list,
        formula1: "lists!$A$10:$#{@rebuilt_types_end_column}$10"
    })


    # Delete
    sheet.add_data_validation("AJ2:AJ1000",
    {
        type: :list,
        formula1: "lists!$A$1:$B$1"
    })

  end

  # header rows
  def header_rows
    detail_row = [
      'RVI ID',
      'Agency Fleet Id',
      'Vehicle Type',
      'Total Vehicles',
      'Active Vehicles']
    detail_row += RailSafetyFeature.all.map{|x| "Total Vehicles with #{x}"}

    detail_row += [
      'Dedicated Fleet',
      'No Capital Replacement Responsibility',
      'Automated or Autonomous Vehicle',
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
      'Emergency Contingency Vehicles',
      "Type of Last Renewal",
      'Useful Life Benchmark',
      'Useful Life Remaining',
      'Miles This Year',
      'Avg Lifetime Miles per Active Vehicle',
      'Status',
      'Notes',
      'Delete'
    ]

    [detail_row]
  end

  def column_styles
    styles = []
    unless @has_rail_safety_features
      styles += [
          {:name => 'gray', :column => 5},
          {:name => 'gray', :column => 6},
          {:name => 'gray', :column => 7},
          {:name => 'gray', :column => 8}
      ]
    end

    styles += [
      {:name => 'gray', :column => 13},
      {:name => 'gray', :column => 18},
      {:name => 'gray', :column => 19},
      {:name => 'gray', :column => 24},
      {:name => 'gray', :column => 30}
    ]
    styles
  end

  def row_styles
    styles = []
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
    a << {name: 'lt-gray', bg_color: "00A9A9A9"}
    a << { name: 'gray', bg_color: "00A9A9A9"}
    a.flatten
  end

  private

  def initialize(*args)
    super
  end

end
