class TransitNewInventoryTemplateBuilder < TemplateBuilder

  SHEET_NAME = TransitNewInventoryFileHandler::SHEET_NAME

  protected

  def add_rows(sheet)

  end

  def setup_workbook(workbook)

    # ------------------------------------------------
    #
    # Tab for lookup tables
    #
    # ------------------------------------------------

    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'

    @asset_subtypes = @asset_types.map(&:asset_subtypes).flatten
    @fta_funding_types = FtaFundingType.active.pluck(:name)
    @fta_ownership_types = FtaOwnershipType.active.pluck(:name)
    @fta_vehicle_types = FtaVehicleType.active.pluck(:name) # row 4
    @fuel_types = FuelType.active.pluck(:name) # row 5
    @fta_facility_types = FtaFacilityType.active.pluck(:name) # row 6
    @facility_capacity_types = FacilityCapacityType.active.pluck(:name) # row 7
    @manufacturers = Manufacturer.where(filter: @asset_types.map(&:class_name)).active.pluck(:name)
    @orgs = Organization.all.pluck(:name)

    sheet.add_row @asset_subtypes # row 1
    sheet.add_row @fta_funding_types # row 2
    sheet.add_row @fta_ownership_types # row 3
    sheet.add_row @fta_vehicle_types # row 4
    sheet.add_row @fuel_types # row 5
    sheet.add_row @fta_facility_types # row 6
    sheet.add_row @facility_capacity_types # row 7

    # add booleans
    sheet.add_row ['YES', 'NO'] #row 8

    # add manufcaturers
    sheet.add_row @manufacturers # row 9

    # add orgs
    sheet.add_row @orgs # row 10


    # ------------------------------------------------
    #
    # Tab for defaults
    #
    # ------------------------------------------------

    alphabet = ('A'..'Z').to_a
    alphabet.concat(alphabet.map{|xx| 'A'+xx})
    earliest_date = SystemConfig.instance.epoch

    default_sheet = workbook.add_worksheet :name => 'Defaults'
    default_sheet.sheet_protection.password = 'transam'

    defaults_col_fields = default_sheet.styles.add_style({:bg_color => "DDD9C4"})
    defaults_col_entries = default_sheet.styles.add_style({:bg_color => "EBF1DE",:locked => false})

    row_style = [defaults_col_fields, defaults_col_entries]

    default_sheet.add_row ['USE DEFAULTS?', nil, 'Except where default always set.'], :style => row_style

    default_sheet.add_row ['Purchased New', nil, 'Default always set to yes.'], :style => row_style
    default_sheet.add_row ['Purchase Date', nil, "Default always set to today's date."], :style => row_style
    default_sheet.add_row ['In Service Date', nil, "Default always set to today's date."], :style => row_style

    default_sheet.add_row ['FTA Funding Type', nil], :style => row_style

    if is_vehicle? or is_rail?
      default_sheet.add_row ['FTA Ownership Type', nil], :style => row_style
      default_sheet.add_row ['FTA Vehicle Type', nil], :style => row_style

      default_sheet.add_row ['Manufacturer', nil], :style => row_style
      default_sheet.add_row ['Manufacturer Year', nil, "Default always set to today's year."], :style => row_style
      default_sheet.add_row ['Title Owner', nil], :style => row_style
      if is_vehicle?
        default_sheet.add_row ['Fuel Type', nil], :style => row_style
      end
    elsif is_facility?
      default_sheet.add_row ['Land Ownership Type', nil], :style => row_style
      default_sheet.add_row ['Building Ownership Type', nil], :style => row_style
      default_sheet.add_row ['FTA Facility Type', nil], :style => row_style
      default_sheet.add_row ['Section of Larger Facility', nil], :style => row_style
      if is_type? 'TransitFacility'
        default_sheet.add_row ['ADA Accessible Ramp', nil], :style => row_style
      elsif is_type? 'SupportFacility'
        default_sheet.add_row ['Facility Capacity Type', nil], :style => row_style
      end
    end

    default_sheet.add_data_validation("B1", {
      :type => :list,
      :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Use Defaults',
      :prompt => 'Only values in the list are allowed'})

    default_sheet.add_data_validation("B2", {
      :type => :list,
      :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchased New',
      :prompt => 'Only values in the list are allowed'})

    default_sheet.add_data_validation("B5", {
      :type => :list,
      :formula1 => "lists!$A$2:$#{alphabet[@fta_funding_types.size]}$2",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'FTA Funding Type',
      :prompt => 'Only values in the list are allowed'})

    if is_vehicle? or is_rail?
      # FTA Ownership Type
      default_sheet.add_data_validation("B6", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # FTA Vehicle Type
      default_sheet.add_data_validation("B7", {
        :type => :list,
        :formula1 => "lists!$A$4:$#{alphabet[@fta_vehicle_types.size]}$4",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Vehicle Type',
        :prompt => 'Only values in the list are allowed'})

      # Manufacturer
      default_sheet.add_data_validation("B8", {
        :type => :list,
        :formula1 => "lists!$A$9:$#{alphabet[@manufacturers.size/26]}#{alphabet[@manufacturers.size%26]}$9",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacturer',
        :prompt => 'Only values in the list are allowed'})

      # Manufacture Year
      sheet.add_data_validation("B9", {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.year.to_s,
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacture Year',
        :prompt => "Only values greater than #{earliest_date.year}"})

      # Title Owner
      default_sheet.add_data_validation("B10", {
        :type => :list,
        :formula1 => "lists!$A$10:$#{alphabet[@manufacturers.size/26]}#{alphabet[@manufacturers.size%26]}$10",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title Owner',
        :prompt => 'Only values in the list are allowed'})

      if is_vehicle?
        # Fuel Type
        default_sheet.add_data_validation("B11", {
          :type => :list,
          :formula1 => "lists!$A$5:$#{alphabet[@fuel_types.size]}$5",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Fuel Type',
          :prompt => 'Only values in the list are allowed'})
      end

    elsif is_facility?
      # Land Ownership Type
      default_sheet.add_data_validation("B6", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Land Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # Buildng Ownership Type
      default_sheet.add_data_validation("B7", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Building Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # FTA Facility Type
      default_sheet.add_data_validation("B8", {
        :type => :list,
        :formula1 => "lists!$A$6:$#{alphabet[@fta_facility_types.size]}$6",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Fuel Type',
        :prompt => 'Only values in the list are allowed'})

      default_sheet.add_data_validation("B9", {
        :type => :list,
        :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Section of Larger Facility',
        :prompt => 'Only values in the list are allowed'})


      if is_type? 'TransitFacility'
        default_sheet.add_data_validation("B10", {
          :type => :list,
          :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'ADA Accessible Ramp',
          :prompt => 'Only values in the list are allowed'})
      elsif is_type? 'SupportFacility'
        # Facility Capacity Type
        default_sheet.add_data_validation("B10", {
          :type => :list,
          :formula1 => "lists!$A$7:$#{alphabet[@facility_capacity_types.size]}$7",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Fuel Type',
          :prompt => 'Only values in the list are allowed'})
      end
    end

  end


  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    #sheet.sheet_protection.password = 'transam'

    sheet.merge_cells("A1:D1")
    if is_type? 'Vehicle'
      sheet.merge_cells("H1:P1")
    elsif is_type? 'SupportVehicle'
      sheet.merge_cells("H1:O1")
    elsif is_facility?
      sheet.merge_cells("H1:T1")
    elsif is_type? 'RailCar'
      sheet.merge_cells("H1:N1")
    elsif is_type? 'Locomotive'
      sheet.merge_cells("E1:M1")
    end

    alphabet = ('A'..'Z').to_a
    alphabet.concat(alphabet.map{|xx| 'A'+xx})
    earliest_date = SystemConfig.instance.epoch

    # asset subtype
    sheet.add_data_validation("A3:A500", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@asset_subtypes.size]}$1",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Asset Subtype',
      :prompt => 'Only values in the list are allowed'})

    # Purchased New
    sheet.add_data_validation("C3:C500", {
      :type => :list,
      :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchased New',
      :prompt => 'Only values in the list are allowed'})

    # Purchase date
    sheet.add_data_validation("E3:E500", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchase Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # In service date
    sheet.add_data_validation("F3:F500", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'In Service Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # FTA funding type
    sheet.add_data_validation("G3:G500", {
      :type => :list,
      :formula1 => "lists!$A$2:$#{alphabet[@fta_funding_types.size]}$2",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'FTA Funding Type',
      :prompt => 'Only values in the list are allowed'})

    if is_vehicle?
      # Manufacturer
      sheet.add_data_validation("H3:H500", {
        :type => :list,
        :formula1 => "lists!$A$9:$#{alphabet[@manufacturers.size/26]}#{alphabet[@manufacturers.size%26]}$9",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacturer',
        :prompt => 'Only values in the list are allowed'})


      # Manufacture Year
      sheet.add_data_validation("J3:J500", {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.year.to_s,
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacture Year',
        :prompt => "Only values greater than #{earliest_date.year}"})

      # Title Owner
      sheet.add_data_validation("K3:K500", {
        :type => :list,
        :formula1 => "lists!$A$10:$#{alphabet[@manufacturers.size/26]}#{alphabet[@manufacturers.size%26]}$10",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title Owner',
        :prompt => 'Only values in the list are allowed'})

      # FTA Ownership Type
      sheet.add_data_validation("L3:L500", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # FTA Vehicle Type
      sheet.add_data_validation("M3:M500", {
        :type => :list,
        :formula1 => "lists!$A$4:$#{alphabet[@fta_vehicle_types.size]}$4",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Vehicle Type',
        :prompt => 'Only values in the list are allowed'})

      # Fuel Type
      sheet.add_data_validation("N3:N500", {
        :type => :list,
        :formula1 => "lists!$A$5:$#{alphabet[@fuel_types.size]}$5",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Fuel Type',
        :prompt => 'Only values in the list are allowed'})

      if is_type? 'Vehicle'
        # Vehicle Length > 0
        sheet.add_data_validation("P3:P5000", {
          :type => :whole,
          :operator => :greaterThan,
          :formula1 => '0',
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Length must be > 0',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Vehicle length',
          :prompt => 'Only values greater than 0'})
      end
    elsif is_facility?
      # State
      sheet.add_data_validation("K3:K500", {
        :type => :textLength,
        :operator => :equal,
        :formula1 => '2',
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Not abbreviation',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'State',
        :prompt => 'State abbreviation'})

      # Land Ownership Type
      sheet.add_data_validation("M3:M500", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Land Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # Building Ownership Type
      sheet.add_data_validation("N3:N500", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Building Ownership Type',
        :prompt => 'Only values in the list are allowed'})
      # Section of Larger Facility
      sheet.add_data_validation("Q3:Q500", {
        :type => :list,
        :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Section of Larger Facility',
        :prompt => 'Only values in the list are allowed'})

      # FTA Facility Type
      sheet.add_data_validation("S3:S500", {
        :type => :list,
        :formula1 => "lists!$A$6:$#{alphabet[@fta_facility_types.size]}$6",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Fuel Type',
        :prompt => 'Only values in the list are allowed'})
      if is_type? 'TransitFacility'
        # ADA Accessible Ramp
        sheet.add_data_validation("T3:T500", {
          :type => :list,
          :formula1 => "lists!$A$8:$#{alphabet[2]}$8",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Fuel Type',
          :prompt => 'Only values in the list are allowed'})
      elsif is_type? 'SupportFacility'
        # Facility Capacity Type
        sheet.add_data_validation("T3:T500", {
          :type => :list,
          :formula1 => "lists!$A$7:$#{alphabet[@facility_capacity_types.size]}$7",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Fuel Type',
          :prompt => 'Only values in the list are allowed'})
      end
    elsif is_rail?
      # Manufacturer
      sheet.add_data_validation("H3:H500", {
        :type => :list,
        :formula1 => "lists!$A$9:$#{alphabet[@manufacturers.size/26]}#{alphabet[@manufacturers.size%26]}$9",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacturer',
        :prompt => 'Only values in the list are allowed'})

      # Manufacture Year
      sheet.add_data_validation("J3:J500", {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.year.to_s,
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacture Year',
        :prompt => "Only values greater than #{earliest_date.year}"})

      # Title Owner
      sheet.add_data_validation("K3:K500", {
        :type => :list,
        :formula1 => "lists!$A$10:$#{alphabet[@manufacturers.size/26]}#{alphabet[@manufacturers.size%26]}$10",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title Owner',
        :prompt => 'Only values in the list are allowed'})

      # FTA Ownership Type
      sheet.add_data_validation("L3:L500", {
        :type => :list,
        :formula1 => "lists!$A$3:$#{alphabet[@fta_ownership_types.size]}$3",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # FTA Vehicle Type
      sheet.add_data_validation("M3:M500", {
        :type => :list,
        :formula1 => "lists!$A$4:$#{alphabet[@fta_vehicle_types.size]}$4",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Vehicle Type',
        :prompt => 'Only values in the list are allowed'})

      if is_type? 'RailCar'
        # Vehicle Length > 0
        sheet.add_data_validation("N3:N5000", {
          :type => :whole,
          :operator => :greaterThan,
          :formula1 => '0',
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Length must be > 0',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Vehicle length',
          :prompt => 'Only values greater than 0'})
      end
    end

  end


  def header_rows
   title_row = [
      'Asset',
      '',
      '',
      '',
      '',
      '',
      '',
    ]
    if is_vehicle?
      title_row.concat([
        'Features',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ])
      if is_type? 'Vehicle'
        title_row.concat([''])
      end
    elsif is_facility?
      title_row.concat([
        'Location',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ])
    elsif is_rail?
      title_row.concat([
        'Features',
        '',
        '',
        '',
        '',
        ''
      ])
      if is_type? 'RailCar'
        title_row.concat([''])
      end
    end


    detail_row = [
      'Subtype',
      'Tag',
      'Purchased New',
      'Purchase Cost',
      'Purchase Date',
      'In Service Date',
      'FTA Funding Type'
    ]
    if is_vehicle?
      detail_row.concat([
        'Manufacturer',
        'Model',
        'Manufacture Year',
        'Title Owner',
        'FTA Ownership Type',
        'FTA Vehicle Type',
        'Fuel Type',
        'VIN'
      ])
      if is_type? 'Vehicle'
        detail_row.concat(['Vehicle Length'])
      end
    elsif is_facility?
      detail_row.concat([
        'Description',
        'Address1',
        'City',
        'State',
        'Zip',
        'Land Ownership',
        'Building Ownership',
        'Lot Size',
        'Facility Size',
        'Section of Larger Facility',
        'Pcnt Operational',
        'FTA Facility Type'
      ])
      if is_type? 'TransitFacility'
        detail_row.concat(['ADA Accessible Ramp'])
      elsif is_type? 'SupportFacility'
        detail_row.concat(['Facility Capacity Type'])
      end
    elsif is_rail?
      detail_row.concat([
        'Manufacturer',
        'Model',
        'Manufacture Year',
        'Title Owner',
        'FTA Ownership Type',
        'FTA Vehicle Type'
      ])
      if is_type? 'RailCar'
        detail_row.concat(['Vehicle Length'])
      end
    end

    return [title_row, detail_row]
  end

  def column_styles
    styles = [
      {:name => 'asset_col_string', :column => 0},
      {:name => 'asset_col_string', :column => 1},
      {:name => 'asset_col_string', :column => 2},
      {:name => 'asset_col_currency', :column => 3},
      {:name => 'asset_col_date', :column => 4},
      {:name => 'asset_col_date', :column => 5},
      {:name => 'asset_col_string', :column => 6}
    ]

    if is_vehicle?
      styles.concat([
        {:name => 'feature_col_string', :column => 7},
        {:name => 'feature_col_string', :column => 8},
        {:name => 'feature_col_integer', :column => 9},
        {:name => 'feature_col_string', :column => 10},
        {:name => 'feature_col_string', :column => 11},
        {:name => 'feature_col_string', :column => 12},
        {:name => 'feature_col_string', :column => 13},
        {:name => 'feature_col_string', :column => 14}
      ])
      if is_type? 'Vehicle'
        styles.concat([{:name => 'feature_col_integer', :column => 15}])
      end
    elsif is_facility?
      styles.concat([
        {:name => 'feature_col_string', :column => 7},
        {:name => 'feature_col_string', :column => 8},
        {:name => 'feature_col_string', :column => 9},
        {:name => 'feature_col_string', :column => 10},
        {:name => 'feature_col_string', :column => 11},
        {:name => 'feature_col_string', :column => 12},
        {:name => 'feature_col_string', :column => 13},
        {:name => 'feature_col_float', :column => 14},
        {:name => 'feature_col_integer', :column => 15},
        {:name => 'feature_col_string', :column => 16},
        {:name => 'feature_col_pcnt', :column => 17},
        {:name => 'feature_col_string', :column => 18},
        {:name => 'feature_col_string', :column => 19}
      ])
    elsif is_rail?
      styles.concat([
        {:name => 'feature_col_string', :column => 7},
        {:name => 'feature_col_string', :column => 8},
        {:name => 'feature_col_integer', :column => 9},
        {:name => 'feature_col_string', :column => 10},
        {:name => 'feature_col_string', :column => 11},
        {:name => 'feature_col_string', :column => 12}
      ])
      if is_type? 'RailCar'
        styles.concat([{:name => 'feature_col_integer', :column => 13}])
      end
    end

    styles
  end

  def row_types
    types = [
      # Asset
      :string,
      :string,
      :string,
      :integer,
      :date,
      :date,
      :string
    ]

    if is_vehicle?
      types.concat([
        :string,
        :string,
        :integer,
        :string,
        :string,
        :string,
        :string,
        :string
      ])
      if is_type? 'Vehicle'
        types.concat([:integer])
      end
    elsif is_facility?
      types.concat([
        :string,
        :string,
        :string,
        :string,
        :string,
        :string,
        :string,
        :float,
        :integer,
        :string,
        :integer,
        :string,
        :string
      ])
    elsif is_rail?
      types.concat([
        :string,
        :string,
        :integer,
        :string,
        :string,
        :string
      ])
      if is_type? 'RailCar'
        types.concat([:integer])
      end
    end

    types
  end

  def styles

    a = []
    a << super

    a << {:name => 'asset_col_string', :bg_color => "EBF1DE", :fg_color => '000000', :b => true, :alignment => { :horizontal => :left }, :locked => false }
    a << {:name => 'asset_col_currency', :num_fmt => 5, :bg_color => "EBF1DE", :alignment => { :horizontal => :center }, :locked => false }
    a << {:name => 'asset_col_date', :format_code => 'MM/DD/YYYY', :bg_color => "EBF1DE", :alignment => { :horizontal => :center }, :locked => false }

    a << {:name => 'feature_col_string', :bg_color => "DDD9C4", :fg_color => '000000', :b => true, :alignment => { :horizontal => :left }, :locked => false }
    a << {:name => 'feature_col_float', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :right } , :locked => false }
    a << {:name => 'feature_col_integer', :num_fmt => 3, :bg_color => "DDD9C4", :alignment => { :horizontal => :right } , :locked => false }
    a << {:name => 'feature_col_pcnt', :num_fmt => 9, :bg_color => "DDD9C4", :alignment => { :horizontal => :right } , :locked => false }

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
  end

  def is_vehicle?
    class_names = @asset_types.map(&:class_name)
    class_names.include? "Vehicle" or class_names.include? "SupportVehicle"
  end

  def is_rail?
    class_names = @asset_types.map(&:class_name)
    class_names.include? "RailCar" or class_names.include? "Locomotive"
  end

  def is_facility?
    class_names = @asset_types.map(&:class_name)
    class_names.include? "TransitFacility" or class_names.include? "SupportFacility"
  end

  def is_type? klass
    @asset_types.map(&:class_name).include? klass
  end

end
