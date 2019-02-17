class TransitInfrastructureTrackSubcomponentTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME


  def setup_instructions()
    instructions = [
        '• Components & Sub-Componentstab contains a table where users should enter asset data. Users should enter 1 component / sub-component asset selection per row and 1 attribute per column',
        '• For Characteristics: There are seven unique Component / Sub-Component types in the Characteristics section - Rail, Ties, Fasteners-Spikes & Screws, Fasteners-Supports, Field Welds, Joints and Ballast.  Only data for a single component / sub-component should be entered per row. i.e. if you wish to enter data for Rail and Ties, this requires two separate rows of data entry. In addition, if you wish to enter three types of Rail records, this requires three separate rows of data entry.',
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        '• Asset / Segment IDs and Row Names are frozen to assist in scrolling through the table',
        '• For Vendor: Initially, all clients have only an Other option available.  When selecting Other, add a value in the corresponding Other field. Over time the available options will be updated.',
        "• For Program/Pcnt: The system's front-end is configured to add as many combination values as needed. We have provided you with four values for each.",
        '• Contract/Purchase Order (PO) # and Contract / PO Type can additionally be customized to have multiple values. This field is meant to contain different types of Contract/PO types. If applicable, select the value that applies best.',
        '• The List of Fields tab displays a table of all the attributes sorted by color (required status)'
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
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Asset / Segment ID', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('tracks_for_subcomponents')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Component Id', 'Characteristics', {name: 'required_string'})

    template.add_column(sheet, 'Component / Sub-Component', 'Characteristics', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('subcomponents_for_track')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Component ID',
        :prompt => 'Only values in the list are allowed'})

    #
    #
    template.add_column(sheet, 'Description', 'Characteristics - Rail', {name: 'recommended_string'})

    template.add_column(sheet, 'Manufacturer', 'Characteristics - Rail', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Rail', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Rail', {name: 'recommended_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year of Construction',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Quantity / Length', 'Characteristics - Rail', {name: 'recommended_integer'})

    template.add_column(sheet, 'Quantity Unit', 'Characteristics - Rail', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('rail_length_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Superstructure Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Weight', 'Characteristics - Rail', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Rail', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('rail_weight_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Superstructure Materials',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Rail Type', 'Characteristics - Rail', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_rail_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Rail Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Rail Joining', 'Characteristics - Rail', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_rail_joining')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Rail Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Ties', {name: 'recommended_string'})

    template.add_column(sheet, 'Quantity', 'Characteristics - Ties', {name: 'recommended_integer'})
    template.add_column(sheet, 'Manufacturer', 'Characteristics - Ties', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Ties', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Manufacture', 'Characteristics - Ties', {name: 'recommended_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year of Manufacture',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Tie / Ballastless Form', 'Characteristics - Ties', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_ties_ballastless_forms')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie / Ballastless Form',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Tie Material', 'Characteristics - Ties', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('tie_materials')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie Material',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Fasteners (Spikes & Screws)', {name: 'recommended_string'})

    template.add_column(sheet, 'Quantity', 'Characteristics - Fasteners (Spikes & Screws)', {name: 'recommended_integer'})
    template.add_column(sheet, 'Manufacturer', 'Characteristics - Fasteners (Spikes & Screws)', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Fasteners (Spikes & Screws)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Manufacture', 'Characteristics - Fasteners (Spikes & Screws)', {name: 'recommended_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year of Manufacture',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Screw & Spike Type', 'Characteristics - Fasteners (Spikes & Screws)', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('screw_spike_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie / Ballastless Form',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'})

    template.add_column(sheet, 'Quantity', 'Characteristics - Fasteners (Supports)', {name: 'recommended_integer'})
    template.add_column(sheet, 'Manufacturer', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Manufacture', 'Characteristics - Fasteners (Supports)', {name: 'recommended_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year of Manufacture',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Support Type', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_fasteners_support_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie / Ballastless Form',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Field Welds', {name: 'recommended_string'})
    template.add_column(sheet, 'Quantity', 'Characteristics - Field Welds', {name: 'recommended_integer'})
    template.add_column(sheet, 'Weld Type', 'Characteristics - Field Welds', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_weld_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie / Ballastless Form',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Quantity', 'Characteristics - Joints', {name: 'recommended_integer'})
    template.add_column(sheet, 'Manufacturer', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Year of Manufacture', 'Characteristics - Joints', {name: 'recommended_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year of Manufacture',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Joint Type', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_joint_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie / Ballastless Form',
        :prompt => 'Only values in the list are allowed'})
    #
    #
    template.add_column(sheet, 'Description', 'Characteristics - Ballast', {name: 'recommended_string'})
    template.add_column(sheet, 'Quantity', 'Characteristics - Ballast', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Rail', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_ballast_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Superstructure Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Manufacturer', 'Characteristics - Ballast', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Year of Manufacture', 'Characteristics - Joints', {name: 'recommended_year'}, {
        :type => :whole,
        :operator => :between,
        :formula1 => earliest_date.strftime("%Y"),
        :formula2 => Date.today.strftime("%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Year must be after #{earliest_date.year}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Year of Manufacture',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

    template.add_column(sheet, 'Ballast Type', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_ballast_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie / Ballastless Form',
        :prompt => 'Only values in the list are allowed'})

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

    template.add_column(sheet, 'Vendor', 'Procurement & Purchase', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('vendors')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Contract/PO Type',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Vendor (Other)', 'Procurement & Purchase', {name: 'other_string'})

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

    template.add_column(sheet, 'Warranty Expiration Date', 'Procurement & Purchase', {name: 'recommended_date'}, {
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

  end


  def post_process(sheet)
    sheet.sheet_view.pane do |pane|
      pane.top_left_cell = "A1"
      pane.state = :frozen_split
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
    asset.external_id = cells[@external_id_column_number[1]]
    asset.description = cells[@description_column_number[1]]
    asset.location_name = cells[@location_column_number[1]]
    asset.from_line = cells[@line_from_line_column_number[1]]
    asset.from_segment = cells[@line_from_from_column_number[1]]
    asset.to_line = cells[@line_to_line_column_number[1]]
    asset.to_segment = cells[@line_to_to_column_number[1]]
    asset.relative_location_unit = cells[@unit_column_number[1]]
    asset.from_location_name = cells[@from_location_column_number[1]]
    asset.to_location_name = cells[@to_location_column_number[1]]
    asset.fta_asset_class = FtaAssetClass.find_by(name: cells[@class_column_number[1]])
    asset.fta_type = FtaFacilityType.find_by(name: cells[@type_column_number[1]])

    asset_classification =  cells[@subtype_column_number[1]].to_s.split(' - ')
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification[0], asset_type: AssetType.find_by(name: asset_classification[1]))

    infrastructure_segment_type = InfrastructureSegmentType.find_by(name: cells[@segment_type_column_number[1]])
    asset.infrastructure_segment_type = infrastructure_segment_type

    mainline = InfrastructureDivision.find_by(name: cells[@mainline_column_number[1]], organization_id: asset.organization.id)
    asset.infrastructure_division = mainline

    branch = InfrastructureSubdivision.find_by(name: cells[@mainline_column_number[1]])
    asset.infrastructure_subdivision = branch

    asset.num_tracks = cells[@number_of_tracks_column_number[1]]

    bridge_type = InfrastructureBridgeType.find_by(name: cells[@bridge_type_column_number[1]])
    asset.infrastructure_bridge_type = bridge_type
    asset.num_spans = cells[@number_of_spans_column_number[1]]
    asset.num_decks = cells[@number_of_decks_column_number[1]]

    crossing = InfrastructureCrossing.find_by(name: cells[@crossing_column_number[1]])
    asset.infrastructure_crossing = crossing

    asset.length = cells[@length_1_column_number[1]]
    asset.length_unit = cells[@length_unit_1_column_number[1]]
    asset.height = cells[@length_2_column_number[1]]
    asset.height_unit = cells[@length_unit_2_column_number[1]]
    asset.width = cells[@length_3_column_number[1]]
    asset.width_unit = cells[@length_unit_3_column_number[1]]

    if (cells[@direct_capital_responsibility_column_number[1]].upcase == 'YES')
      asset.pcnt_capital_responsibility = cells[@percent_capital_responsibility_column_number[1]].to_i
    end

    organization_with_shared_capital_responsitbility = cells[@organization_with_shared_capital_responsibility_column_number[1]]
    asset.shared_capital_responsibility_organization = organization_with_shared_capital_responsitbility

    priamry_mode_type_string = cells[@priamry_mode_column_number[1]].to_s.split(' - ')[1]
    asset.primary_fta_mode_type = FtaModeType.find_by(name: priamry_mode_type_string)
    asset.primary_fta_service_type = FtaServiceType.find_by(name: cells[@service_type_primary_mode_column_number[1]])
    asset.nearest_city = cells[@nearest_city_column_number[1]]
    asset.nearest_state = cells[@state_purchase_column_number[1]]

    land_owner_name = cells[@land_owner_column_number[1]]
    unless land_owner_name.nil?
      asset.land_ownership_organization = Organization.find_by(name: land_owner_name)
      if(land_owner_name == 'Other')
        asset.land_owner_name = cells[@land_owner_other_column_number[1]]
      end
    end

  end

  def set_events(asset, cells, columns)
    @add_processing_message = []

    unless(cells[@odometer_reading_column_number[1]].nil? || cells[@date_last_odometer_reading_column_number[1]].nil?)
      m = MileageUpdateEventLoader.new
      m.process(asset, [cells[@odometer_reading_column_number[1]], cells[@date_last_odometer_reading_column_number[1]]] )

      event = m.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Mileage Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

    end

    unless(cells[@condition_column_number[1]].nil? || cells[@date_last_condition_reading_column_number[1]].nil?)
      c = ConditionUpdateEventLoader.new
      c.process(asset, [cells[@condition_column_number[1]], cells[@date_last_condition_reading_column_number[1]]] )

      event = c.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Condition Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end
    end

    unless cells[@rebuild_rehabilitation_total_cost_column_number[1]].nil? ||
        (cells[@rebuild_rehabilitation_extend_useful_life_miles_column_number[1]].nil? && cells[@rebuild_rehabilitation_extend_useful_life_months_column_number[1]].nil?) ||
        cells[@date_of_rebuild_rehabilitation_column_number[1]].nil?
      r = RebuildRehabilitationUpdateEventLoader.new
      cost = cells[ @rebuild_rehabilitation_total_cost_column_number[1]]
      months = cells[@rebuild_rehabilitation_extend_useful_life_months_column_number[1]]
      miles = cells[@rebuild_rehabilitation_extend_useful_life_miles_column_number[1]]
      r.process(asset, [cost, months, miles, cells[@date_of_rebuild_rehabilitation_column_number[1]]] )

      event = r.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Rebuild Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

    end


    unless(cells[@service_status_column_number[1]].nil? || cells[@date_of_last_service_status_column_number[1]].nil?)
      s= ServiceStatusUpdateEventLoader.new
      s.process(asset, [cells[@service_status_column_number[1]], cells[@date_of_last_service_status_column_number[1]]] )

      event = s.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Status Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

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
    'Infra - Track Components'
  end

  def set_initial_asset(cells)
    asset = Guideway.new
    asset_classification =  cells[@subtype_column_number[1]].to_s.split(' - ')
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification[0], asset_type: AssetType.find_by(name: asset_classification[1]))
    asset.asset_tag = cells[@asset_id_column_number[1]]

    asset
  end

  def get_messages_to_process
    @add_processing_message
  end

  private

  def green_label_cells
    green_label_cells = [
        @agency_column_number,
        @asset_id_column_number,
        @line_from_line_column_number,
        @line_from_from_column_number,
        @line_to_line_column_number,
        @line_to_to_column_number,
        @unit_column_number,
        @class_column_number,
        @type_column_number,
        @subtype_column_number,
        @segment_type_column_number,
        @mainline_column_number,
        @branch_column_number,
        @direct_capital_responsibility_column_number,
        @percent_capital_responsibility_column_number,
        @organization_with_shared_capital_responsibility_column_number,
        @priamry_mode_column_number,
        @service_type_primary_mode_column_number,
        @service_status_column_number,
        @date_of_last_service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
        @external_id_column_number,
        @description_column_number,
        @location_column_number,
        @from_location_column_number,
        @to_location_column_number,
        @number_of_tracks_column_number,
        @bridge_type_column_number,
        @number_of_spans_column_number,
        @number_of_decks_column_number,
        @crossing_column_number,
        @length_1_column_number,
        @length_unit_1_column_number,
        @length_2_column_number,
        @length_unit_2_column_number,
        @length_3_column_number,
        @length_unit_3_column_number,
        @nearest_city_column_number,
        @state_purchase_column_number,
        @land_owner_column_number,
        @infrastructure_owner_column_number,
        @condition_column_number,
        @date_last_condition_reading_column_number,
    ]
  end

  def grey_label_cells
    grey_label_cells = [
        @land_owner_other_column_number,
        @infrastructure_owner_other_column_number,
    ]
  end

  def initialize(*args)
    super

    # Define sections
    @identificaiton_and_classification_column_number = RubyXL::Reference.ref2ind('A1')
    @characteristics_bridges_only_column_number = RubyXL::Reference.ref2ind('T1')
    @characteristics_bridges_tunnels_column_number = RubyXL::Reference.ref2ind('V1')
    @geometry_column_number = RubyXL::Reference.ref2ind('X1')
    @operations_column_number = RubyXL::Reference.ref2ind('AG1')
    @registartion_column_number = RubyXL::Reference.ref2ind('AK1')
    @funding_column_number =  RubyXL::Reference.ref2ind('AD1')
    @initial_event_data_column_number = RubyXL::Reference.ref2ind('AO1')
    @last_known_column_number = RubyXL::Reference.ref2ind('BV1')

    # Define light green columns
    @agency_column_number = RubyXL::Reference.ref2ind('A2')
    @asset_id_column_number = RubyXL::Reference.ref2ind('B2')
    @component_id_column_number = RubyXL::Reference.ref2ind('C2')
    @component_sub_component_column_number = RubyXL::Reference.ref2ind('D2')

    @roll_description_column_number = RubyXL::Reference.ref2ind('E2')
    @roll_manufacturer_column_number = RubyXL::Reference.ref2ind('F2')
    @roll_model_column_number = RubyXL::Reference.ref2ind('G2')
    @roll_year_of_manufacture_column_number = RubyXL::Reference.ref2ind('H2')
    @roll_length_column_number = RubyXL::Reference.ref2ind('I2')
    @roll_length_unit_column_number = RubyXL::Reference.ref2ind('J2')
    @roll_weight_column_number = RubyXL::Reference.ref2ind('K2')
    @roll_weight_unit_column_number = RubyXL::Reference.ref2ind('L2')
    @roll_rail_type_column_number = RubyXL::Reference.ref2ind('M2')
    @roll_rail_joining_type_column_number = RubyXL::Reference.ref2ind('N2')

    @ties_description_column_number = RubyXL::Reference.ref2ind('O2')
    @ties_quantity_column_description = RubyXL::Reference.ref2ind('P2')
    @ties_manufacturer_column_number = RubyXL::Reference.ref2ind('Q2')
    @ties_model_column_number = RubyXL::Reference.ref2ind('R2')
    @ties_year_of_manufacture_column_number = RubyXL::Reference.ref2ind('S2')
    @ties_tie_ballastless_form_column_number = RubyXL::Reference.ref2ind('T2')
    @ties_tie_material_column_number = RubyXL::Reference.ref2ind('U2')

    @fasteners_spikes_description_column_number = RubyXL::Reference.ref2ind('V2')
    @fasteners_spikes_quantity_column_description = RubyXL::Reference.ref2ind('W2')
    @fasteners_spikes_manufacturer_column_number = RubyXL::Reference.ref2ind('X2')
    @fasteners_spikes_model_column_number = RubyXL::Reference.ref2ind('Y2')
    @fasteners_spikes_year_of_construction_column_number = RubyXL::Reference.ref2ind('Z2')
    @fasteners_spikes_screw_type_column_number = RubyXL::Reference.ref2ind('AA2')

    @fasteners_support_description_column_number = RubyXL::Reference.ref2ind('AB2')
    @fasteners_support_quantity_column_description = RubyXL::Reference.ref2ind('AC2')
    @fasteners_support_manufacturer_column_number = RubyXL::Reference.ref2ind('AD2')
    @fasteners_support_model_column_number = RubyXL::Reference.ref2ind('AE2')
    @fasteners_support_year_of_construction_column_number = RubyXL::Reference.ref2ind('AF2')
    @fasteners_support_support_type_column_number = RubyXL::Reference.ref2ind('AG2')

    @field_welds_description_column_number = RubyXL::Reference.ref2ind('AH2')
    @field_welds_quantity_column_description = RubyXL::Reference.ref2ind('AI2')
    @field_welds_weld_type_column_number = RubyXL::Reference.ref2ind('AJ2')

    @joints_description_column_number = RubyXL::Reference.ref2ind('AK2')
    @joints_quantity_column_description = RubyXL::Reference.ref2ind('AL2')
    @joints_manufacturer_column_number = RubyXL::Reference.ref2ind('AM2')
    @joints_model_column_number = RubyXL::Reference.ref2ind('AN2')
    @joints_year_of_construction_column_number = RubyXL::Reference.ref2ind('AO2')
    @joints_joint_type_column_number = RubyXL::Reference.ref2ind('AP2')

    @ballast_description_column_number = RubyXL::Reference.ref2ind('AQ2')
    @ballast_quantity_column_description = RubyXL::Reference.ref2ind('AR2')
    @ballast_unit_column_number = RubyXL::Reference.ref2ind('AS2')
    @ballast_manufacturer_column_number = RubyXL::Reference.ref2ind('AT2')
    @ballast_model_column_number = RubyXL::Reference.ref2ind('AU2')
    @ballast_year_of_construction_column_number = RubyXL::Reference.ref2ind('AV2')
    @ballast_type_column_number = RubyXL::Reference.ref2ind('AW2')

    @program_1_column_number = RubyXL::Reference.ref2ind('AX2')
    @percent_1_column_number = RubyXL::Reference.ref2ind('AY2')
    @program_2_column_number =	RubyXL::Reference.ref2ind('AZ2')
    @percent_2_column_number = RubyXL::Reference.ref2ind('BA2')
    @program_3_column_number = RubyXL::Reference.ref2ind('BB2')
    @percent_3_column_number = RubyXL::Reference.ref2ind('BC2')
    @program_4_column_number = RubyXL::Reference.ref2ind('BD2')
    @percent_4_column_number = RubyXL::Reference.ref2ind('BE2')
    @cost_purchase_column_number = RubyXL::Reference.ref2ind('BF2')

    @purchased_new_column_number = RubyXL::Reference.ref2ind('BJ2')
    @purchase_date_column_number = RubyXL::Reference.ref2ind('BH2')
    @contract_purchase_order_column_number = RubyXL::Reference.ref2ind('BI2')
    @contract_po_type_column_number = RubyXL::Reference.ref2ind('BJ2')
    @vendor_column_number = RubyXL::Reference.ref2ind('BK2')
    @vendor_other_column_number = RubyXL::Reference.ref2ind('BL2')
    @warranty_column_number = RubyXL::Reference.ref2ind('BM2')
    @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('BN2')
    @in_service_date_column_number = RubyXL::Reference.ref2ind('BO2')

  end

  def get_messages_to_process
    @add_processing_message
  end


end