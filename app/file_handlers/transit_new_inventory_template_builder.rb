class TransitNewInventoryTemplateBuilder < UpdatedTemplateBuilder

  SHEET_NAME = TransitNewInventoryFileHandler::SHEET_NAME

  protected

  def setup_workbook(workbook)
    super

    @default_values = {}

    styles.each do |s|
      @style_cache[s[:name]] = workbook.styles.add_style(s)
    end

    # add instructions
    instructions = [
      "Every asset type has a minimum set of fields that are required to define a given asset as well as additional fields that, while not required, provide supplementary asset information.To quickly get your data into the system, you can complete this template spreadsheet that lists both required as well as optional fields.",
      "Every column in the spreadsheet represents an asset attribute and each row represents one asset. Attributes are split into four categories: Type, Purchase, FTA Reporting, and Characteristics. Required attribute columns are highlighted with a '*'. Furthermore, the first row shows the systems built in defaults for when cells are left blank, and allows the user to set additional default values.",
      "While the system can process hundreds of rows of assets at a time, if a required field is missing or entered incorrectly the system will respond in one of two ways: (1) if a required field is left blank and the field has no default, the system will throw an error and the invalid row will not load into the system; or (2)  if a required field is left blank but has a default value set, it will default the empty entry to the configured value and the asset will load into the system.",
      "Note that cells need to be entered correctly to pass validations. For instance, some of the attributes such as 'FTA Mode Types' and 'Vehicle Characteristics' are multi-select values so, when applicable, should list multiple values seperated by commas."
    ]

    instructions_sheet = workbook.add_worksheet :name => 'Instructions'
    instructions_sheet.sheet_protection.password = 'transam'

    instructions_sheet.add_row ['New Inventory Instructions'], :style => workbook.styles.add_style({:sz => 18, :fg_color => 'ffffff', :bg_color => '5e9cd3'})
    instructions_sheet.add_row [nil] # blank line
    instruction_style = workbook.styles.add_style({:bg_color => 'BED7ED', :alignment => {:wrap_text => true}})
    instructions.each do |i|
      instructions_sheet.add_row [i], :style => instruction_style
      instructions_sheet.add_row [nil], :style => instruction_style # blank line
    end

    instructions_sheet.column_widths *[100]
  end

  def setup_lookup_sheet(workbook)
    super

    # ------------------------------------------------
    #
    # Tab for lookup tables
    #
    # ------------------------------------------------

    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'


    tables = [
      'fta_funding_types', 'fta_ownership_types', 'fta_vehicle_types', 'fuel_types', 'fta_facility_types', 'facility_capacity_types', 'vehicle_rebuild_types', 'leed_certification_types', 'fta_mode_types', 'fta_service_types', 'service_status_types'
    ]

    row_index = 1
    tables.each do |lookup|
      row = lookup.classify.constantize.active.pluck(:name)
      @lookups[lookup] = {:row => row_index, :count => row.count}
      sheet.add_row row
      row_index+=1
    end

    # ADD BOOLEAN_ROW
    @lookups['booleans'] = {:row => row_index, :count => 2}
    sheet.add_row ['YES', 'NO']
    row_index+=1

    # asset_subtypes
    # make loading equipmnet easier can load more than one asset type if same eqipment class
    if @asset_types.map(&:class_name).flatten.include? 'Equipment'
      row = AssetType.where(class_name: 'Equipment').map(&:asset_subtypes).flatten
    else
      row = @asset_types.map(&:asset_subtypes).flatten
    end
    @lookups['asset_subtypes'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # manufacturers
    row = Manufacturer.where(filter: @asset_types.map(&:class_name)).active.pluck(:name)
    @lookups['manufacturers'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # vendors
    # row = Vendor.where(organization: @organization).active.pluck(:name)
    # @lookups['vendors'] = {:row => row_index, :count => row.count}
    # sheet.add_row row
    # row_index+=1

    #units
    row = Uom.units
    @lookups['units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1


    row = Organization.where(id: @organization_list).pluck(:name)
    @lookups['organizations'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1
  end

  def add_columns(sheet)

    add_column(sheet, '*Asset Subtype', 'Type', {name: 'type_string'}, {
      :type => :list,
      :formula1 => "lists!#{get_lookup_cells('asset_subtypes')}",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Asset Subtype',
      :prompt => 'Only values in the list are allowed'})

    add_column(sheet, '*Asset Tag', 'Type', {name: 'type_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '32',
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Tag',
        :prompt => 'Text length must be less than ar equal to 32'})

    add_column(sheet, '*Purchased New', 'Purchase', {name: 'purchase_string'}, {
      :type => :list,
      :formula1 => "lists!#{get_lookup_cells('booleans')}",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchased New',
      :prompt => 'Only values in the list are allowed'}, 'default_values', 'YES')

    add_column(sheet, '*Purchase Cost', 'Purchase', {name: 'purchase_currency'}, {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => '0',
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Must be >= 0',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchase Cost',
      :prompt => 'Only values greater than or equal to 0'})

    add_column(sheet, '*Purchase Date', 'Purchase', {name: 'purchase_date'}, {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => EARLIEST_DATE.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Purchase Date',
      :prompt => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}"}, 'default_values', Date.today.strftime('%m/%d/%Y'))

    add_column(sheet, '*In Service Date', 'Purchase', {name: 'purchase_date'}, {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => EARLIEST_DATE.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'In Service Date',
      :prompt => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}"}, 'default_values', Date.today.strftime('%m/%d/%Y'))

    add_column(sheet, 'Warranty Date', 'Purchase', {name: 'purchase_date'}, {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => EARLIEST_DATE.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,

      :errorTitle => 'Wrong input',
      :error => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Warranty Date',
      :prompt => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}"})

    # accounting columns
    if SystemConfig.transam_module_names.include? "accounting"
      add_column(sheet, 'Depreciation Start Date', 'Purchase', {name: 'purchase_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => EARLIEST_DATE.strftime("%-m/%d/%Y"),
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Depreciation Start Date',
        :prompt => "Date must be after #{EARLIEST_DATE.strftime("%-m/%d/%Y")}"}, 'default_values', Date.today.strftime('%m/%d/%Y'))

      add_column(sheet, 'Salvage Value', 'Purchase', {name: 'purchase_currency'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Salvage Value',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', '0')
    end

    add_column(sheet, 'Vendor', 'Purchase', {name: 'purchase_string'}, {
      :type => :textLength,
      :operator => :lessThanOrEqual,
      :formula1 => '32',
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Too long text length',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Vendors',
      :prompt => 'Text length must be less than ar equal to 32'
    })

    add_column(sheet, '*FTA Funding Type', 'FTA Reporting', {name: 'fta_string'}, {
      :type => :list,
      :formula1 => "lists!#{get_lookup_cells('fta_funding_types')}",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'FTA Funding Type',
      :prompt => 'Only values in the list are allowed'})

    add_column(sheet, 'External ID', 'Type', {name: 'type_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '32',
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'External ID',
        :prompt => 'Text length must be less than ar equal to 32'})

    if is_type? 'Equipment'
      add_column(sheet, 'Serial Number', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '32',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Serial Number',
          :prompt => 'Text length must be less than ar equal to 32'})
      add_column(sheet, 'Quantity', 'Type', {name: 'type_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity',
        :prompt => 'Only values greater than 0'}, 'default_values', 1)

      add_column(sheet, 'Quantity Units', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('units')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity Units',
        :prompt => 'Only values in the list are allowed'}, 'default_values', 'unit')
    elsif is_vehicle? || is_rail?
      # Manufacturer
      add_column(sheet, '*Manufacturer', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('manufacturers')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacturer',
        :prompt => 'Only values in the list are allowed'})

      add_column(sheet, '*Manufacturer Model', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '128',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Manufacturer Model',
          :prompt => 'Text length must be less than ar equal to 128'})

      # Manufacture Year
      add_column(sheet, '*Manufacture Year', 'Type', {name: 'type_string'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => EARLIEST_DATE.strftime("%Y"),
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{EARLIEST_DATE.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Manufacture Year',
        :prompt => "Only values greater than #{EARLIEST_DATE.year}"}, 'default_values', Date.today.year.to_s)

      # FTA Ownership Type
      add_column(sheet, '*FTA Ownership Type', 'FTA Reporting', {name: 'fta_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('fta_ownership_types')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      # FTA Vehicle Type
      add_column(sheet, '*FTA Vehicle Type', 'FTA Reporting', {name: 'fta_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('fta_vehicle_types')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Vehicle Type',
        :prompt => 'Only values in the list are allowed'})

      # Title Owner
      add_column(sheet, '*Title Owner', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title Owner',
        :prompt => 'Only values in the list are allowed'})

      add_column(sheet, 'Title Number', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '32',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Title Number',
          :prompt => 'Text length must be less than ar equal to 32'})

      if !(is_type? 'Locomotive')
        add_column(sheet, 'License Plate', 'Type', {name: 'type_string'}, {
            :type => :textLength,
            :operator => :lessThanOrEqual,
            :formula1 => '32',
            :allow_blank => false,
            :showErrorMessage => true,
            :errorTitle => 'Wrong input',
            :error => 'Too long text length',
            :errorStyle => :stop,
            :showInputMessage => true,
            :promptTitle => 'License Plate',
            :prompt => 'Text length must be less than ar equal to 32'})

        add_column(sheet, 'Gross Vehicle Weight', 'Characteristics', {name: 'characteristics_integer'}, {
          :type => :whole,
          :operator => :greaterThan,
          :formula1 => '0',
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Must be > 0',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Gross vehicle weight',
          :prompt => 'Only values greater than 0'})

        add_column(sheet, 'Seating Capacity', 'Characteristics', {name: 'characteristics_integer'}, {
          :type => :whole,
          :operator => :greaterThanOrEqual,
          :formula1 => '0',
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Must be >= 0',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Seating Capacity',
          :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)

        if (is_type? 'Vehicle') || (is_type? 'RailCar')
          add_column(sheet, 'Standing Capacity', 'Characteristics', {name: 'characteristics_integer'}, {
              :type => :whole,
              :operator => :greaterThanOrEqual,
              :formula1 => '0',
              :allow_blank => true,
              :showErrorMessage => true,
              :errorTitle => 'Wrong input',
              :error => 'Must be >= 0',
              :errorStyle => :stop,
              :showInputMessage => true,
              :promptTitle => 'Standing Capacity',
              :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)

          add_column(sheet, 'Wheelchair Capacity', 'Characteristics', {name: 'characteristics_integer'}, {
              :type => :whole,
              :operator => :greaterThanOrEqual,
              :formula1 => '0',
              :allow_blank => true,
              :showErrorMessage => true,
              :errorTitle => 'Wrong input',
              :error => 'Must be >= 0',
              :errorStyle => :stop,
              :showInputMessage => true,
              :promptTitle => 'Wheelchair Capacity',
              :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)
        end

      else
        add_column(sheet, 'FTA Emergency Contingency Fleet', 'FTA Reporting', {name: 'fta_string'}, {
          :type => :list,
          :formula1 => "lists!#{get_lookup_cells('booleans')}",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'FTA Emergency Contingency Fleet',
          :prompt => 'Only values in the list are allowed'})
      end
      if !(is_type? 'SupportVehicle')
        # Vehicle Length > 0
        add_column(sheet, '*Vehicle Length', 'Characteristics', {name: 'characteristics_integer'}, {
          :type => :whole,
          :operator => :greaterThan,
          :formula1 => '0',
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Must be > 0',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Vehicle length',
          :prompt => 'Only values greater than 0'}, 'default_values', 0)

        add_column(sheet, 'Rebuild Year', 'Characteristics', {name: 'characteristics_string'}, {
          :type => :whole,
          :operator => :greaterThanOrEqual,
          :formula1 => EARLIEST_DATE.year.to_s,
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => "Year must be after #{EARLIEST_DATE.year}",
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Rebuild Year',
          :prompt => "Only values greater than #{EARLIEST_DATE.year}"})

        add_column(sheet, '*FTA Mode Types', 'FTA Reporting', {name: 'fta_string'}, {
          # :type => :list,
          :type => :custom,
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'FTA Mode Types',
          :prompt => "(separate with commas): #{FtaModeType.active.pluck(:code).join(', ')}"})

        add_column(sheet, '*FTA Service Types', 'FTA Reporting', {name: 'fta_string'}, {
          :type => :custom,
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'FTA Service Types',
          :prompt => "(separate with commas): #{FtaServiceType.active.pluck(:name).join(', ')}"})
      else
        add_column(sheet, 'Pcnt Capital Responsibility', 'FTA Reporting', {name: 'fta_pcnt'}, {
          :type => :whole,
          :operator => :between,
          :formula1 => '0',
          :formula2 => '100',
          :allow_blank => true,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Must be a percent',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Pcnt Capital Responsibility',
          :prompt => 'Whole percentage'}, 'default_values', 100)
      end

      if is_vehicle?
        # Fuel Type
        add_column(sheet, '*Fuel Type', 'Characteristics', {name: 'characteristics_string'}, {
          :type => :list,
          :formula1 => "lists!#{get_lookup_cells('fuel_types')}",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Fuel Type',
          :prompt => 'Only values in the list are allowed'})

        add_column(sheet, '*VIN', 'Type', {name: 'type_string'}, {
            :type => :textLength,
            :operator => :lessThanOrEqual,
            :formula1 => '32',
            :allow_blank => false,
            :showErrorMessage => true,
            :errorTitle => 'Wrong input',
            :error => 'Too long text length',
            :errorStyle => :stop,
            :showInputMessage => true,
            :promptTitle => 'VIN',
            :prompt => 'Text length must be less than ar equal to 32'})
      end

      if (is_type? 'Vehicle') || (is_type? 'RailCar')
        add_column(sheet, 'ADA Accessible Lift', 'FTA Reporting', {name: 'fta_string'}, {
          :type => :list,
          :formula1 => "lists!#{get_lookup_cells('booleans')}",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'ADA Accessible Lift',
          :prompt => 'Only values in the list are allowed'})
        if is_type? 'Vehicle'
          add_column(sheet, 'Vehicle Rebuild Type', 'Characteristics', {name: 'characteristics_integer'}, {
            :type => :list,
            :formula1 => "lists!#{get_lookup_cells('vehicle_rebuild_types')}",
            :allow_blank => false,
            :showErrorMessage => true,
            :errorTitle => 'Wrong input',
            :error => 'Select a value from the list',
            :errorStyle => :stop,
            :showInputMessage => true,
            :promptTitle => 'Vehicle Rebuild Type',
            :prompt => 'Only values in the list are allowed'})
        elsif is_type? 'RailCar'
          add_column(sheet, 'ADA Accessible Ramp', 'FTA Reporting', {name: 'fta_string'}, {
            :type => :list,
            :formula1 => "lists!#{get_lookup_cells('booleans')}",
            :allow_blank => false,
            :showErrorMessage => true,
            :errorTitle => 'Wrong input',
            :error => 'Select a value from the list',
            :errorStyle => :stop,
            :showInputMessage => true,
            :promptTitle => 'ADA Accessible Ramp',
            :prompt => 'Only values in the list are allowed'})
        end

        add_column(sheet, '*Vehicle Features', 'Characteristics', {name: 'characteristics_string'}, {
          :type => :custom,
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Vehicle Features',
          :prompt => "(separate with commas): #{VehicleFeature.active.pluck(:name).join(', ')}"})
      end
    elsif is_facility?
      add_column(sheet, '*Description', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '128',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Description',
          :prompt => 'Text length must be less than ar equal to 128'})

      add_column(sheet, '*Address1', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '128',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Address1',
          :prompt => 'Text length must be less than ar equal to 128'})

      add_column(sheet, '*Address2', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '128',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Address2',
          :prompt => 'Text length must be less than ar equal to 128'})

      add_column(sheet, '*City', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '64',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'City',
          :prompt => 'Text length must be less than ar equal to 64'})

      # State
      add_column(sheet, '*State', 'Type', {name: 'type_string'}, {
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
        :prompt => 'State abbreviation'}, 'default_values', SystemConfig.instance.default_state_code)

      add_column(sheet, '*Zip', 'Type', {name: 'type_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '10',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Zip',
          :prompt => 'Text length must be less than ar equal to 10'})

      # Land Ownership Type
      add_column(sheet, '*Land Ownership Type', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('fta_ownership_types')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Land Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      add_column(sheet, 'Land Owner', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Land Owner',
        :prompt => 'Only values in the list are allowed'})

      # Building Ownership Type
      add_column(sheet, '*Building Ownership Type', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('fta_ownership_types')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Building Ownership Type',
        :prompt => 'Only values in the list are allowed'})

      add_column(sheet, 'Building Owner', 'Type', {name: 'type_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Building Owner',
        :prompt => 'Only values in the list are allowed'})

      add_column(sheet, '*Year Built', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => EARLIEST_DATE.year.to_s,
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{EARLIEST_DATE.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year Built',
        :prompt => "Only values greater than #{EARLIEST_DATE.year}"}, 'default_values', Date.today.year)

      add_column(sheet, '*Lot Size', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Lot Size',
        :prompt => 'Only values greater than or equal to 0'})

      add_column(sheet, '*Facility Size', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Facility Size',
        :prompt => 'Only values greater than or equal to 0'})

      # Section of Larger Facility
      add_column(sheet, '*Section of Larger Facility', 'Characteristics', {name: 'characteristics_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('booleans')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Section of Larger Facility',
        :prompt => 'Only values in the list are allowed'})

      add_column(sheet, '*Pcnt Operational', 'Characterisitics', {name: 'characteristics_pcnt'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => '0',
        :formula2 => '100',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be a percent',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Pcnt Operational',
        :prompt => 'Whole percentage'})

      add_column(sheet, 'Num Structures', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Num Structures',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', 1)

      add_column(sheet, 'Num Floors', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Num Floors',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', 1)

      add_column(sheet, 'Num Elevators', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Num Elevators',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)

      add_column(sheet, 'Num Escalators', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Num Escalators',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)

      add_column(sheet, 'Num Parking Spaces Public', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Num Parking Spaces Public',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)

      add_column(sheet, 'Num Parking Spaces Private', 'Characteristics', {name: 'characteristics_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Num Parking Spaces Private',
        :prompt => 'Only values greater than or equal to 0'}, 'default_values', 0)

      add_column(sheet, 'Line Number', 'Characteristics', {name: 'characteristics_string'}, {
          :type => :textLength,
          :operator => :lessThanOrEqual,
          :formula1 => '128',
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Too long text length',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Line Number',
          :prompt => 'Text length must be less than ar equal to 128'})

      add_column(sheet, 'LEED Certification Type', 'Characteristics', {name: 'characteristics_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('leed_certification_types')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'LEED Certification Type',
        :prompt => 'Only values in the list are allowed'}, 'default_values', 'Not Certified')

      add_column(sheet, 'Facility Features', 'Characteristics', {name: 'characteristics_string'}, {
        :type => :custom,
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Facility Features',
        :prompt => "(separate with commas): #{FacilityFeature.active.pluck(:name).join(', ')}"})

      # FTA Facility Type
      add_column(sheet, '*FTA Facility Type', 'FTA Reporting', {name: 'fta_string'}, {
          :type => :list,
          :formula1 => "lists!#{get_lookup_cells('fta_facility_types')}",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Facility Type',
          :prompt => 'Only values in the list are allowed'})

      add_column(sheet, '*FTA Mode Types', 'FTA Reporting', {name: 'fta_string'}, {
          :type => :list,
          :formula1 => "lists!#{get_lookup_cells('fta_mode_types')}",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'FTA Mode Types',
          :prompt => 'Only values in the list are allowed'})

      add_column(sheet, 'Pcnt Capital Responsibility', 'FTA Reporting', {name: 'fta_pcnt'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => '0',
        :formula2 => '100',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be a percent',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Pcnt Capital Responsibility',
        :prompt => 'Whole percentage'}, 'default_values', 100)

      add_column(sheet, 'FTA Service Types', 'FTA Reporting', {name: 'fta_string'}, {
        :type => :custom,
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'FTA Service Types',
        :prompt => "(separate with commas): #{FtaServiceType.active.pluck(:name).join(', ')}"})

      add_column(sheet, '*ADA Accessible Ramp', 'FTA Reporting', {name: 'fta_string'}, {
        :type => :list,
        :formula1 => "lists!#{get_lookup_cells('booleans')}",
        :allow_blank => false,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Fuel Type',
        :prompt => 'Only values in the list are allowed'})

      if is_type? 'SupportFacility'
        # Facility Capacity Type
        add_column(sheet, '*Facility Capacity Type', 'FTA Reporting', {name: 'fta_string'}, {
          :type => :list,
          :formula1 => "lists!#{get_lookup_cells('facility_capacity_types')}",
          :allow_blank => false,
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Facility Capacity Type',
          :prompt => 'Only values in the list are allowed'})
      end
    end

    # add asset event columns
    add_event_column(sheet, 'ConditionUpdateEvent', {
      :type => :decimal,
      :operator => :between,
      :formula1 => '1.0',
      :formula2 => '5.0',
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Rating value must be between 1 and 5',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Condition Rating',
      :prompt => 'Only values between 1 and 5'})

    add_event_column(sheet, 'ServiceStatusUpdateEvent', {
      :type => :list,
      :formula1 => "lists!#{get_lookup_cells('service_status_types')}",
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Service type',
      :prompt => 'Only values in the list are allowed'})

    if is_vehicle?
      add_event_column(sheet, 'MileageUpdateEvent', {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Milage must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Current mileage',
        :prompt => 'Only values greater than 0'})
    end
  end

  def add_rows(sheet)
    default_row = []
    @header_category_row.each do |key, fields|
      fields.each do |i|
        default_row << (@default_values[i].present? ? @default_values[i] : 'SET DEFAULT')
      end
    end
    sheet.add_row default_row

    1000.times do
      sheet.add_row Array.new(49){nil}
    end
  end

  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # override default row style
    default_row_style = sheet.workbook.styles.add_style({:bg_color => 'EEA2AD'})
    sheet.rows[2].style = default_row_style

  end

  def styles

    a = []

    colors = {type: 'EBF1DE', characteristics: 'B2DFEE', purchase: 'DDD9C4', fta: 'DCE6F1'}


    colors.each do |key, color|
      a << {:name => "#{key}_string", :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true }, :locked => false }
      a << {:name => "#{key}_currency", :num_fmt => 5, :bg_color => color, :alignment => { :horizontal => :left }, :locked => false }
      a << {:name => "#{key}_date", :format_code => 'MM/DD/YYYY', :bg_color => color, :alignment => { :horizontal => :left }, :locked => false }
      a << {:name => "#{key}_float", :num_fmt => 2, :bg_color => color, :alignment => { :horizontal => :left } , :locked => false }
      a << {:name => "#{key}_integer", :num_fmt => 3, :bg_color => color, :alignment => { :horizontal => :left } , :locked => false }
      a << {:name => "#{key}_pcnt", :num_fmt => 9, :bg_color => color, :alignment => { :horizontal => :left } , :locked => false }
    end

    a.flatten
  end

  def column_widths
    [20] * 50
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
