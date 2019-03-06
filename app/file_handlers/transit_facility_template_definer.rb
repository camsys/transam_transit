class TransitFacilityTemplateDefiner

  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME


  def setup_instructions()
    instructions = [
        '• Facilities - Primary tab contains a table where users should enter asset data. Users should enter 1 asset per row and 1 attribute per column',
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        '• Asset IDs and Row Names are frozen to assist in scrolling through the table',
        '• For Model and Vendor: Initially, all clients have only an Other option available.  When selecting Other, add a value in the corresponding Other field. Over time the available options will be updated.',
        "• For Program/Pcnt: The system's front-end is configured to add as many combination values as needed. We have provided you with four values for each.",
        '• Contract/Purchase Order (PO) # and Contract / PO Type can additionally be customized to have multiple values. This field is meant to contain different types of Contract/PO types. If applicable, select the value that',
        '• The List of Fields tab displays a table of all the attributes sorted by color (required status)',
        '• The FTA designates a list of Facility Types. The definitions of those types is listed in the Facility Type - Definitions tab. Use it as a reference as needed.'
    ]
  end

  def setup_lookup_sheet(wrkb, lookups)
    @lookups = lookups
  end

  def add_columns(sheet, template, org, fta_asset_class, earliest_date)

    dark_green_fill = '6BB14A'
    light_green_fill = '6BB14A'
    grey_fill = 'DBDBDB'
    white_fill = '000000'

    # TODO I almost want to make a class that is just all of these column definitions. Then the builder classes are just a list of calls to make up what is needed
    template.add_column(sheet, 'Agency', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Agency',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Asset ID', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'Facility Name', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'External ID', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'NTD ID', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Facility Categorization', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('facility_primary_categorizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Facility Categorization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Country', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('countries')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Country',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Address 1', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'Address 2', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'City', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'State', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('states')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'State',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Zip Code', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'County', 'Identification & Classification', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('counties')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'County',
        :prompt => 'Only values in the list are allowed'})

    # template.add_column(sheet, 'Latitude', 'Identification & Classification', {name: 'other_integer'}, {
    template.add_column(sheet, 'Latitude', 'Identification & Classification', {name: 'other_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Latitude',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'N/S', 'Identification & Classification', {name: 'other_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('latitude_directions')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'N/S',
        :prompt => 'Only values in the list are allowed'})

    # template.add_column(sheet, 'Longitude', 'Identification & Classification', {name: 'other_integer'}, {
    template.add_column(sheet, 'Longitude', 'Identification & Classification', {name: 'other_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Longitude',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'E/W', 'Identification & Classification', {name: 'other_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('longitutde_directions')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'E/W',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Class', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_asset_classes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Type', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('facility_primary_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Subtype', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('asset_subtypes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Estimated Service Life Category', 'Identification & Classification', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('esl_category')}",
        # :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Estimated Service Life Category',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Facility Size', 'Characteristics', {name: 'required_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Facility Size',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Facility Size Units', 'Characteristics', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Facility Size Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Section of a Larger Facility', 'Characteristics', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Section of a Larger Facility',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Year Built', 'Characteristics', {name: 'required_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year Built',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Lot Size', 'Characteristics', {name: 'recommended_integer'})

    template.add_column(sheet, 'Lot Size Units', 'Characteristics', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Lot Size Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'LEED Certification Type', 'Characteristics', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('leed_certification_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'LEED Certification Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'ADA Accessible', 'Characteristics', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'ADA Accessible',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Number of Structures', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('1_to_20')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Structures',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Floors', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('0_to_20')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Floors',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Elevators', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('0_to_20')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Elevators',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Escalators', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('0_to_20')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Escalators',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Parking Spots (public)', 'Characteristics', {name: 'recommended_integer'})

    template.add_column(sheet, 'Number of Parking Spots (private)', 'Characteristics', {name: 'last_recommended_integer'})

    template.add_column(sheet, 'Program #1', 'Funding', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('programs')}",
        # :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Program #1',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Pcnt #1', 'Funding', {name: 'recommended_pcnt'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Pcnt #1',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Program #2', 'Funding', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('programs')}",
        # :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Program #2',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Pcnt #2', 'Funding', {name: 'recommended_pcnt'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Pcnt #2',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Program #3', 'Funding', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('programs')}",
        # :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Program #3',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Pcnt #3', 'Funding', {name: 'recommended_pcnt'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Pcnt #3',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Program #4', 'Funding', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('programs')}",
        # :formula1 => "lists!#{get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Program #4',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Pcnt #4', 'Funding', {name: 'recommended_pcnt'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Pcnt #4',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Cost (Purchase)', 'Funding', {name: 'required_currency'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Purchase Cost',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Direct Capital Responsibility', 'Funding', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Direct Capital Responsibility',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, '% Capital Responsibility', 'Funding', {name: 'last_required_pcnt'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '% Capital Responsibility',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Purchased New', 'Procurement & Purchase', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Purchased New',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['YES'])

    template.add_column(sheet, 'Purchase Date', 'Procurement & Purchase', {name: 'required_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Purchase Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    template.add_column(sheet, 'Contract/Purchase Order (PO) #', 'Procurement & Purchase', {name: 'recommended_string'})

    template.add_column(sheet, 'Contract/PO Type', 'Procurement & Purchase', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('purchase_order_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Contract/PO Type',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Warranty', 'Procurement & Purchase', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Warranty',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['YES'])

    template.add_column(sheet, 'Warranty Expiration Date', 'Procurement & Purchase', {name: 'last_recommended_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Warranty Expiration Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    template.add_column(sheet, 'Operator', 'Operations', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Operator',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Operator (Other)', 'Operations', {name: 'other_string'})

    template.add_column(sheet, 'In Service Date', 'Operations', {name: 'required_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'In Service Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    template.add_column(sheet, 'Features', 'Operations', {name: 'recommended_string'}, {
        :type => :custom,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Features',
        :prompt => "(separate with commas): #{VehicleFeature.active.pluck(:name).join(', ')}"})

    template.add_column(sheet, 'Primary Mode', 'Operations', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_mode_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Primary Mode',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Supports Another Mode', 'Operations', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_mode_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Supports Another Mode',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Private Mode', 'Operations', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_private_mode_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Private Mode',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Vehicle Capacity', 'Operations', {name: 'last_recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('vehicle_capacity')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Vehicle Capacity',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Title  #', 'Registration & Title', {name: 'recommended_string'})

    template.add_column(sheet, 'Title Owner', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title Owner',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Title Owner (Other)', 'Registration & Title', {name: 'other_string'})

    template.add_column(sheet, 'Lienholder', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Lienholder',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Lienholder (Other)', 'Registration & Title', {name: 'other_string'})

    template.add_column(sheet, 'Land Ownership', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Land Ownership',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Land Ownership (Other)', 'Registration & Title', {name: 'other_string'})

    template.add_column(sheet, 'Facility Ownership', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Facility Ownership',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Facility Ownership (Other)', 'Registration & Title', {name: 'last_other_string'})

    template.add_column(sheet, 'Condition', 'Initial Event Data', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Condition',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Date of Last Condition Reading', 'Initial Event Data', {name: 'recommended_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Date of Last Condition Reading',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    template.add_column(sheet, 'Rebuild / Rehabilitation Total Cost', 'Initial Event Data', {name: 'recommended_currency'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Rebuild / Rehab cost',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Rebuild / Rehabilitation Extend Useful Life By (months)', 'Initial Event Data', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Rebuild / Rehab Extend Months',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Date of Rebuild / Rehabilitation', 'Initial Event Data', {name: 'recommended_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Rebuild / Rehab Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    template.add_column(sheet, 'Service Status', 'Initial Event Data', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('service_status_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Status',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Date of Last Service Status', 'Initial Event Data', {name: 'last_required_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Status Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    post_process(sheet)
  end


  def post_process(sheet)
    sheet.sheet_view.pane do |pane|
      pane.top_left_cell = RubyXL::Reference.ind2ref(3,5)
      pane.state = :frozen
      pane.y_split = 2
      pane.x_split = 4
      pane.active_pane = :bottom_right
    end
  end

  def set_columns(asset, cells, columns)
    @add_processing_message = []

    organization = cells[@agency_column_number[1]]
    asset.organization = Organization.find_by(name: organization)
    asset.asset_tag = cells[@asset_id_column_number[1]]
    asset.facility_name = cells[@facility_name_column_number[1]]
    asset.external_id = cells[@external_id_column_number[1]]
    asset.ntd_id = cells[@ntd_id_column_number[1]]
    # @facility_categorization_column_number = RubyXL::Reference.ref2ind('F2')
    asset.country = cells[@country_column_number[1]]
    asset.address1 = cells[@address_one_column_number[1]]
    asset.address2 = cells[@address_two_column_number[1]]
    asset.city = cells[@city_column_number[1]]
    asset.state = cells[@state_column_number[1]]
    asset.zip = cells[@zip_code_column_number[1]]
    asset.county = cells[@county_column_number[1]]
    # cells[@latitude_column_number[1]]
    # cells[@north_south_column_number[1]]
    # cells[@longitute_column_number[1]]
    # cells[@east_west_column_number[1]]
    asset.fta_asset_class = FtaAssetClass.find_by(name: cells[@class_column_number[1]])
    asset.fta_type = FtaFacilityType.find_by(name: cells[@type_column_number[1]])
    asset_classification =  cells[@subtype_column_number[1]].to_s.split(' - ')
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification[0], asset_type: AssetType.find_by(name: asset_classification[1]))
    asset.esl_category = EslCategory.find_by(name: cells[@estimated_service_life_category_column_number[1]])
    asset.fta_asset_category = FtaAssetCategory.find_by(name: 'Facilities')
    asset.facility_size = cells[@facility_size_column_number[1]]
    asset.facility_size_unit = cells[@facility_size_units_column_number[1]]
    asset.section_of_larger_facility = cells[@section_of_a_larger_facility_column_number[1]].upcase == 'YES'
    asset.manufacture_year = cells[@year_built_column_number[1]]
    asset.lot_size = cells[@lot_size_column_number[1]]
    asset.lot_size_unit = cells[@lot_size_units_other_column_number[1]]
    leed_cert_type = LeedCertificationType.find_by(name: cells[@leed_certification_type_column_number[1]])
    leed_cert_type = LeedCertificationType.find_by(name: cells[@leed_certification_type_column_number[1]])
    asset.leed_certification_type = leed_cert_type
    asset.ada_accessible = cells[@ada_accessible_column_number[1]].upcase == 'YES'
    asset.num_structures = cells[@number_of_structures_column_number[1]]
    asset.num_floors = cells[@number_of_floors_column_number[1]]
    asset.num_elevators = cells[@number_of_elevators_column_number[1]]
    asset.num_escalators = cells[@number_of_escalators_column_number[1]]
    asset.num_parking_spaces_public = cells[@number_of_parking_spots_public_column_number[1]]
    asset.num_parking_spaces_private = cells[@number_of_parking_spots_private_column_number[1]]
    asset.facility_capacity_type = cells[@vehicle_capacity_column_number[1]]

    # Lchang provided
    (1..4).each do |grant_purchase_count|
      if cells[eval("@program_#{grant_purchase_count}_column_number")[1]].present? && cells[eval("@percent_#{grant_purchase_count}_column_number")[1]].present?
        grant_purchase = asset.grant_purchases.build
        grant_purchase.sourceable = FundingSource.find_by(name: cells[eval("@program_#{grant_purchase_count}_column_number")[1]])
        grant_purchase.pcnt_purchase_cost = cells[eval("@percent_#{grant_purchase_count}_column_number")[1]].to_i
      end
    end

    asset.purchase_cost = cells[@cost_purchase_column_number[1]]

    if (cells[@direct_capital_responsibility_column_number[1]].upcase == 'YES')
      asset.pcnt_capital_responsibility = cells[@percent_capital_responsibility_column_number[1]].to_i
    end

    asset.purchased_new = cells[@purchased_new_column_number[1]].upcase == 'YES'
    asset.purchase_date = cells[@purchase_date_column_number[1]]
    asset.contract_num = cells[@contract_po_type_column_number[1]]
    asset.contract_type = ContractType.find_by(name: cells[@contract_purchase_order_column_number[1]])
    if(!cells[@warranty_column_number[1]].nil? && cells[@warranty_column_number[1]].upcase == 'YES')
      asset.has_warranty = cells[@warranty_column_number[1]].upcase == 'YES'
      asset.warranty_date = cells[@warranty_expiration_date_column_number[1]]
    else
      asset.has_warranty = false
    end

    operator_name = cells[@operator_column_number[1]]
    asset.operator = Organization.find_by(name: operator_name)
    if(operator_name == 'Other')
      asset.other_operator = cells[@operator_other_column_number[1]]
    end

    asset.in_service_date = cells[@in_service_date_column_number[1]]

    # TODO make this work better
    # asset.vehicle_features = cells[@features_column_number[1]]

    priamry_mode_type_string = cells[@priamry_mode_column_number[1]].to_s.split(' - ')[1]
    asset.primary_fta_mode_type = FtaModeType.find_by(name: priamry_mode_type_string)
    secondary_mode_type_string = cells[@supports_another_mode_column_number[1]].to_s.split(' - ')[1]
    asset.secondary_fta_mode_types = FtaModeType.where(name: secondary_mode_type_string)
    private_mode_type = cells[@private_mode_column_number[1]]
    asset.fta_private_mode_type =  FtaPrivateModeType.find_by(name: private_mode_type)
    asset.title_number = cells[@title_number_column_number[1]]

    title_owner_name = cells[@title_owner_column_number[1]]
    asset.title_ownership_organization = Organization.find_by(name: title_owner_name)
    if(title_owner_name == 'Other')
      asset.other_title_ownership_organization = cells[@title_owner_other_column_number[1]]
    end

    lienholder_name = cells[@lienholder_column_number[1]]
    asset.lienholder = Organization.find_by(name: lienholder_name)
    if(lienholder_name == 'Other')
      asset.other_lienholder = cells[@lienholder_other_column_number[1]]
    end

    land_ownersip = cells[@land_ownership_column_number[1]]
    asset.land_ownership_organization = Organization.find_by(name: lienholder_name)
    if(land_ownersip == 'Other')
      asset.other_land_ownership_organization = cells[@lienholder_other_column_number[1]]
    end

    facility_ownership_organization = cells[@land_ownership_column_number[1]]
    asset.facility_ownership_organization = Organization.find_by(name: lienholder_name)
    if(facility_ownership_organization == 'Other')
      asset.other_facility_ownership_organization = cells[@lienholder_other_column_number[1]]
    end

  end

  def set_events(asset, cells, columns)

    unless(cells[@odometer_reading_column_number[1]].nil? || cells[@date_last_odometer_reading_column_number[1]].nil?)
      m = MileageUpdateEventLoader.new
      m.process(asset, [cells[@odometer_reading_column_number[1]], cells[@date_last_odometer_reading_column_number[1]]] )
    end

    unless(cells[@condition_column_number[1]].nil? || cells[@date_last_condition_reading_column_number[1]].nil?)
      c = ConditionUpdateEventLoader.new
      c.process(asset, [cells[@condition_column_number[1]], cells[@date_last_condition_reading_column_number[1]]] )
    end

    unless cells[@rebuild_rehabilitation_total_cost_column_number[1]].nil? ||
        (cells[@rebuild_rehabilitation_extend_useful_life_miles_column_number[1]].nil? && cells[@rebuild_rehabilitation_extend_useful_life_months_column_number[1]].nil?) ||
        cells[@date_of_rebuild_rehabilitation_column_number[1]].nil?
      r = RebuildRehabilitationUpdateEventLoader.new
      cost = cells[ @rebuild_rehabilitation_total_cost_column_number[1]]
      months = cells[@rebuild_rehabilitation_extend_useful_life_months_column_number[1]]
      miles = cells[@rebuild_rehabilitation_extend_useful_life_miles_column_number[1]]
      r.process(asset, [cost, months, miles, cells[@date_of_rebuild_rehabilitation_column_number[1]]] )
    end


    unless(cells[@service_status_column_number[1]].nil? || cells[@date_of_last_service_status_column_number[1]].nil?)
      s= ServiceStatusUpdateEventLoader.new
      s.process(asset, [cells[@service_status_column_number[1]], cells[@date_of_last_service_status_column_number[1]]] )
    end
  end

  def column_widths
    if @organization
      [20] + [30] + [20] * 48
    else
      [30] + [20] * 49
    end

  end

  def worksheet_name
    'Facilities'
  end

  def set_initial_asset(cells)
    asset = Facility.new
    asset_classification =  cells[@subtype_column_number[1]].to_s.split(' - ')
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification[0], asset_type: AssetType.find_by(name: asset_classification[1]))
    asset.asset_tag = cells[@asset_id_column_number[1]]

    asset
  end

  def get_messages_to_process
    @add_processing_message
  end

  def green_label_cells
    green_label_cells = [
      @agency_column_number,
      @asset_id_column_number,
      @facility_name_column_number,
      @facility_categorization_column_number,
      @country_column_number,
      @address_one_column_number,
      @city_column_number,
      @state_column_number,
      @zip_code_column_number,
      @class_column_number,
      @type_column_number,
      @subtype_column_number,
      @estimated_service_life_category_column_number,
      @facility_size_column_number,
      @facility_size_units_column_number,
      @section_of_a_larger_facility_column_number,
      @year_built_column_number,
      @in_service_date_column_number,
      @primary_mode_column_number,
      @service_status_column_number,
      @date_of_last_service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
      @external_id_column_number,
      @ntd_id_column_number,
      @address_two_column_number,
      @county_column_number,
      @lot_size_units_other_column_number,
      @leed_certification_type_column_number,
      @ada_accessible_column_number,
      @number_of_structures_column_number,
      @number_of_floors_column_number,
      @number_of_elevators_column_number,
      @number_of_escalators_column_number,
      @number_of_parking_spots_public_column_number,
      @number_of_parking_spots_private_column_number,
      @program_1_column_number,
      @percent_1_column_number,
      @program_2_column_number,
      @percent_2_column_number,
      @program_3_column_number,
      @percent_3_column_number,
      @program_4_column_number,
      @percent_4_column_number,
      @cost_purchase_column_number,
      @direct_capital_responsibility_column_number,
      @percent_capital_responsibility_column_number,
      @purchased_new_column_number,
      @purchase_date_column_number,
      @contract_po_type_column_number,
      @contract_purchase_order_column_number,
      @warranty_column_number,
      @warranty_expiration_date_column_number,
      @operator_column_number,
      @features_column_number,
      @supports_another_mode_column_number,
      @private_mode_column_number,
      @vehicle_capacity_column_number,
      @title_number_column_number,
      @title_owner_column_number,
      @lienholder_column_number,
      @land_ownership_column_number,
      @facility_ownership_column_number,
      @condition_column_number,
      @date_last_condition_reading_column_number,
      @rebuild_rehabilitation_total_cost_column_number,
      @rebuild_rehabilitation_extend_useful_life_months_column_number,
      @date_of_rebuild_rehabilitation_column_number,
    ]
  end

  def grey_label_cells
    grey_label_cells = [
      @latitude_column_number,
      @north_south_column_number,
      @longitute_column_number,
      @east_west_column_number,
      @operator_other_column_number,
      @title_owner_other_column_number,
      @lienholder_other_column_number,
      @land_onwership_other_column_number,
      @facility_ownership_other_column_number

    ]
  end

  private

  def initialize(*args)
    super

    # Define sections
    @identificaiton_and_classification_column_number = RubyXL::Reference.ref2ind('A1')
    @characteristics_column_number = RubyXL::Reference.ref2ind('U1')
    @funding_column_number = RubyXL::Reference.ref2ind('AB1')
    @procurement_and_purchase_column_number = RubyXL::Reference.ref2ind('AP1')
    @operations_column_number = RubyXL::Reference.ref2ind('AX1')
    @registration_and_title_column_number = RubyXL::Reference.ref2ind('BG1')
    @initial_event_data_column_number = RubyXL::Reference.ref2ind('BM1')
    @last_known_column_number = RubyXL::Reference.ref2ind('BV1')

    # Define light green columns
    @agency_column_number = RubyXL::Reference.ref2ind('A2')
    @asset_id_column_number = RubyXL::Reference.ref2ind('B2')
    @facility_name_column_number = RubyXL::Reference.ref2ind('C2')
    @external_id_column_number = RubyXL::Reference.ref2ind('D2')
    @ntd_id_column_number =  RubyXL::Reference.ref2ind('E2')
    @facility_categorization_column_number = RubyXL::Reference.ref2ind('F2')
    @country_column_number = RubyXL::Reference.ref2ind('G2')
    @address_one_column_number = RubyXL::Reference.ref2ind('H2')
    @address_two_column_number = RubyXL::Reference.ref2ind('I2')
    @city_column_number = RubyXL::Reference.ref2ind('J2')
    @state_column_number = RubyXL::Reference.ref2ind('K2')
    @zip_code_column_number = RubyXL::Reference.ref2ind('L2')
    @county_column_number = RubyXL::Reference.ref2ind('M2')
    @latitude_column_number = RubyXL::Reference.ref2ind('N2')
    @north_south_column_number = RubyXL::Reference.ref2ind('O2')
    @longitute_column_number = RubyXL::Reference.ref2ind('P2')
    @east_west_column_number = RubyXL::Reference.ref2ind('Q2')
    @class_column_number = RubyXL::Reference.ref2ind('R2')
    @type_column_number = RubyXL::Reference.ref2ind('S2')
    @subtype_column_number = RubyXL::Reference.ref2ind('T2')
    @estimated_service_life_category_column_number = RubyXL::Reference.ref2ind('U2')
    @facility_size_column_number = RubyXL::Reference.ref2ind('V2')
    @facility_size_units_column_number = RubyXL::Reference.ref2ind('W2')
    @section_of_a_larger_facility_column_number = RubyXL::Reference.ref2ind('X2')
    @year_built_column_number = RubyXL::Reference.ref2ind('Y2')
    @lot_size_column_number = RubyXL::Reference.ref2ind('Z2')
    @lot_size_units_other_column_number = RubyXL::Reference.ref2ind('AA2')
    @leed_certification_type_column_number = RubyXL::Reference.ref2ind('AB2')
    @ada_accessible_column_number = RubyXL::Reference.ref2ind('AC2')
    @number_of_structures_column_number = RubyXL::Reference.ref2ind('AD2')
    @number_of_floors_column_number = RubyXL::Reference.ref2ind('AE2')
    @number_of_elevators_column_number = RubyXL::Reference.ref2ind('AF2')
    @number_of_escalators_column_number = RubyXL::Reference.ref2ind('AG2')
    @number_of_parking_spots_public_column_number = RubyXL::Reference.ref2ind('AH2')
    @number_of_parking_spots_private_column_number = RubyXL::Reference.ref2ind('AI2')
    @program_1_column_number = RubyXL::Reference.ref2ind('AJ2')
    @percent_1_column_number = RubyXL::Reference.ref2ind('AK2')
    @program_2_column_number =	RubyXL::Reference.ref2ind('AL2')
    @percent_2_column_number = RubyXL::Reference.ref2ind('AM2')
    @program_3_column_number = RubyXL::Reference.ref2ind('AN2')
    @percent_3_column_number = RubyXL::Reference.ref2ind('AO2')
    @program_4_column_number = RubyXL::Reference.ref2ind('AP2')
    @percent_4_column_number = RubyXL::Reference.ref2ind('AQ2')
    @cost_purchase_column_number = RubyXL::Reference.ref2ind('AR2')
    @direct_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AS2')
    @percent_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AT2')
    @purchased_new_column_number = RubyXL::Reference.ref2ind('AU2')
    @purchase_date_column_number = RubyXL::Reference.ref2ind('AV2')
    @contract_purchase_order_column_number = RubyXL::Reference.ref2ind('AW2')
    @contract_po_type_column_number = RubyXL::Reference.ref2ind('AX2')
    @warranty_column_number = RubyXL::Reference.ref2ind('AY2')
    @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('AZ2')
    @operator_column_number = RubyXL::Reference.ref2ind('BA2')
    @operator_other_column_number = RubyXL::Reference.ref2ind('BCB')
    @in_service_date_column_number = RubyXL::Reference.ref2ind('BC2')
    @features_column_number = RubyXL::Reference.ref2ind('BD2')
    @primary_mode_column_number = RubyXL::Reference.ref2ind('BE2')
    @supports_another_mode_column_number = RubyXL::Reference.ref2ind('BF2')
    @private_mode_column_number = RubyXL::Reference.ref2ind('BG2')
    @vehicle_capacity_column_number = RubyXL::Reference.ref2ind('BH2')
    @title_number_column_number = RubyXL::Reference.ref2ind('BI2')
    @title_owner_column_number = RubyXL::Reference.ref2ind('BJ2')
    @title_owner_other_column_number = RubyXL::Reference.ref2ind('BK2')
    @lienholder_column_number = RubyXL::Reference.ref2ind('BL2')
    @lienholder_other_column_number = RubyXL::Reference.ref2ind('BM2')
    @land_ownership_column_number = RubyXL::Reference.ref2ind('BN2')
    @land_onwership_other_column_number = RubyXL::Reference.ref2ind('BO2')
    @facility_ownership_column_number = RubyXL::Reference.ref2ind('BP2')
    @facilitye_ownership_other_column_number = RubyXL::Reference.ref2ind('BQ2')
    @condition_column_number = RubyXL::Reference.ref2ind('BR2')
    @date_last_condition_reading_column_number = RubyXL::Reference.ref2ind('BS2')
    @rebuild_rehabilitation_total_cost_column_number = RubyXL::Reference.ref2ind('BT2')
    @rebuild_rehabilitation_extend_useful_life_months_column_number = RubyXL::Reference.ref2ind('BU2')
    @date_of_rebuild_rehabilitation_column_number = RubyXL::Reference.ref2ind('BV2')
    @service_status_column_number = RubyXL::Reference.ref2ind('BW2')
    @date_of_last_service_status_column_number = RubyXL::Reference.ref2ind('BX2')

  end


end