class TransitInfrastructureTrackSubcomponentTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  def asset_tag_column_number
    @asset_id_column_number[1]
  end

  def setup_instructions()
    instructions = [
        '• Components and Sub-Componentstab contains a table where users should enter asset data. Users should enter 1 component / sub-component asset selection per row and 1 attribute per column',
        '• For Characteristics: There are seven unique Component / Sub-Component types in the Characteristics section - Rail, Ties, Fasteners-Spikes and Screws, Fasteners-Supports, Field Welds, Joints and Ballast.  Only data for a single component / sub-component should be entered per row. i.e. if you wish to enter data for Rail and Ties, this requires two separate rows of data entry. In addition, if you wish to enter three types of Rail records, this requires three separate rows of data entry.',
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
    template.add_column(sheet, 'Organization', 'Identification and Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Asset / Segment ID', 'Identification and Classification', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('tracks_for_subcomponents')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset / Segment ID',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Component Id', 'Characteristics', {name: 'required_string'})

    template.add_column(sheet, 'Component / Sub-Component', 'Characteristics', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('subcomponents_for_track')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Component / Sub-Component',
        :prompt => 'Only values in the list are allowed'})

    #
    #
    template.add_column(sheet, 'Rail Description', 'Characteristics - Rail', {name: 'recommended_string'})

    template.add_column(sheet, 'Rail Manufacturer', 'Characteristics - Rail', {name: 'recommended_string'})
    template.add_column(sheet, 'Rail Model', 'Characteristics - Rail', {name: 'recommended_string'})

    template.add_column(sheet, 'Rail Year of Construction', 'Characteristics - Rail', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Rail Quantity / Length', 'Characteristics - Rail', {name: 'recommended_integer'})

    template.add_column(sheet, 'Rail Quantity Unit', 'Characteristics - Rail', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('rail_length_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Rail Weight', 'Characteristics - Rail', {name: 'recommended_integer'})

    template.add_column(sheet, 'Rail Weight Unit', 'Characteristics - Rail', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('rail_weight_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
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

    template.add_column(sheet, 'Rail Joining', 'Characteristics - Rail', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_rail_joining')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Rail Joining',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Tie Description', 'Characteristics - Ties', {name: 'recommended_string'})

    template.add_column(sheet, 'Tie Quantity', 'Characteristics - Ties', {name: 'recommended_integer'})
    template.add_column(sheet, 'Tie Manufacturer', 'Characteristics - Ties', {name: 'recommended_string'})
    template.add_column(sheet, 'Tie Model', 'Characteristics - Ties', {name: 'recommended_string'})

    template.add_column(sheet, 'Tie Year of Manufacture', 'Characteristics - Ties', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Tie Material', 'Characteristics - Ties', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('tie_materials')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Tie Material',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Screw and Spike Description', 'Characteristics - Fasteners (Spikes and Screws)', {name: 'recommended_string'})

    template.add_column(sheet, 'Screw and Spike Quantity', 'Characteristics - Fasteners (Spikes and Screws)', {name: 'recommended_integer'})
    template.add_column(sheet, 'Screw and Spike Manufacturer', 'Characteristics - Fasteners (Spikes and Screws)', {name: 'recommended_string'})
    template.add_column(sheet, 'Screw and Spike Model', 'Characteristics - Fasteners (Spikes and Screws)', {name: 'recommended_string'})

    template.add_column(sheet, 'Screw and Spike Year of Manufacture', 'Characteristics - Fasteners (Spikes and Screws)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Screw and Spike Type', 'Characteristics - Fasteners (Spikes and Screws)', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('screw_spike_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Screw and Spike Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Support Description', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'})

    template.add_column(sheet, 'Support Quantity', 'Characteristics - Fasteners (Supports)', {name: 'recommended_integer'})
    template.add_column(sheet, 'Support Manufacturer', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'})
    template.add_column(sheet, 'Support Model', 'Characteristics - Fasteners (Supports)', {name: 'recommended_string'})

    template.add_column(sheet, 'Support Year of Manufacture', 'Characteristics - Fasteners (Supports)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Support Type', 'Characteristics - Fasteners (Supports)', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_fasteners_support_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Support Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Weld Description', 'Characteristics - Field Welds', {name: 'recommended_string'})
    template.add_column(sheet, 'Weld Quantity', 'Characteristics - Field Welds', {name: 'recommended_integer'})
    template.add_column(sheet, 'Weld Type', 'Characteristics - Field Welds', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_weld_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Weld Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Joint Description', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Joint Quantity', 'Characteristics - Joints', {name: 'recommended_integer'})
    template.add_column(sheet, 'Joint Manufacturer', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Joint Model', 'Characteristics - Joints', {name: 'recommended_string'})
    template.add_column(sheet, 'Joint Year of Manufacture', 'Characteristics - Joints', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Joint Type', 'Characteristics - Joints', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_joint_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Joint Type',
        :prompt => 'Only values in the list are allowed'})
    #
    #
    template.add_column(sheet, 'Ballast Description', 'Characteristics - Ballast', {name: 'recommended_string'})
    template.add_column(sheet, 'Ballast Quantity', 'Characteristics - Ballast', {name: 'recommended_integer'})

    template.add_column(sheet, 'Ballast Unit', 'Characteristics - Ballast', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_ballast_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Ballast Manufacturer', 'Characteristics - Ballast', {name: 'recommended_string'})
    template.add_column(sheet, 'Ballast Model', 'Characteristics - Ballast', {name: 'recommended_string'})
    template.add_column(sheet, 'Ballast Year of Manufacture', 'Characteristics - Ballast', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Ballast Type', 'Characteristics - Ballast', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_ballast_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Ballast Type',
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

    template.add_column(sheet, 'Cost (Purchase)', 'Funding', {name: 'last_required_currency'}, {
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

    template.add_column(sheet, 'Purchased New', 'Procurement and Purchase', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Purchased New',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['YES'])

    template.add_column(sheet, 'Purchase Date', 'Procurement and Purchase', {name: 'required_date'}, {
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

    template.add_column(sheet, 'Contract/Purchase Order (PO) #', 'Procurement and Purchase', {name: 'recommended_string'})

    template.add_column(sheet, 'Contract/PO Type', 'Procurement and Purchase', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('purchase_order_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Contract/PO Type',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Vendor', 'Procurement and Purchase', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('vendors')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Vendor',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, 'Vendor (Other)', 'Procurement and Purchase', {name: 'other_string'})

    template.add_column(sheet, 'Warranty', 'Procurement and Purchase', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Warranty',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['YES'])

    template.add_column(sheet, 'Warranty Expiration Date', 'Procurement and Purchase', {name: 'last_recommended_date'}, {
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

    template.add_column(sheet, 'In Service Date', 'Operations', {name: 'last_required_date'}, {
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

    post_process(sheet)
  end


  def post_process(sheet)
    sheet.sheet_view.pane do |pane|
      pane.top_left_cell = RubyXL::Reference.ind2ref(2,4)
      pane.state = :frozen
      pane.y_split = 2
      pane.x_split = 4
      pane.active_pane = :bottom_right
    end
  end

  def set_columns(asset, cells, columns)
    @add_processing_message = []

    asset.fta_asset_category = FtaAssetCategory.find_by(name: 'Infrastructure')

    organization = cells[@agency_column_number[1]].to_s.split(' : ').last
    asset.organization = Organization.find_by(name: organization)

    asset.asset_tag = cells[@component_id_column_number[1]]
    component_and_subtype = cells[@component_sub_component_column_number[1]].to_s.split(' - ')
    component_subtype_name = component_and_subtype[1]

    component_type = ComponentType.find_by(name: component_and_subtype[0])
    # component_subtype = ComponentSubtype.find_by(name: component_and_subtype[0], parent_id: component_type.id)
    asset.component_type = component_type

    asset.manufacturer_id = Manufacturer.find_by(code: 'ZZZ', filter: 'Equipment').id
    asset.manufacturer_model_id = ManufacturerModel.find_by(name: 'Other').id

    if component_type.name == 'rail'
      asset.description = cells[@rail_description_column_number[1]]
      asset.manufacture_year = cells[@rail_year_of_manufacture_column_number[1]]
      asset.other_manufacturer = cells[@rail_manufacturer_column_number[1]]
      asset.other_manufacturer_model = cells[@rail_model_column_number[1]]

      asset.infrastructure_measurement = cells[@rail_length_column_number[1]]
      asset.infrastructure_measurement_unit = cells[@rail_length_unit_column_number[1]]

      asset.infrastructure_weight = cells[@rail_weight_column_number[1]]
      asset.infrastructure_weight_unit = cells[@rail_weight_unit_column_number[1]]

      asset.infrastructure_rail_joining = InfrastructureRailJoining.find_by(name: cells[@rail_rail_joining_type_column_number[1]])

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@rail_rail_type_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Ties'
      asset.description = cells[@ties_description_column_number[1]]
      asset.quantity = cells[@@ties_quantity_column_description[1]]
      asset.manufacture_year = cells[@ties_year_of_manufacture_column_number[1]]
      asset.other_manufacturer = cells[@ties_manufacturer_column_number[1]]
      asset.other_manufacturer_model = cells[@ties_model_column_number[1]]

      asset.infrastructure_measurement = cells[@rail_length_column_number[1]]
      asset.infrastructure_measurement_unit = cells[@rail_length_unit_column_number[1]]

      asset.infrastructure_weight = cells[@rail_weight_column_number[1]]
      asset.infrastructure_weight_unit = cells[@rail_weight_unit_column_number[1]]

      asset.component_material = ComponentMaterial.find_by(name: cells[@ties_tie_material_column_number[1]])

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@ties_tie_ballastless_form_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Fasteners'
      if component_subtype_name == 'Spikes & Screws'

        asset.description = cells[@fasteners_spikes_description_column_number[1]]
        asset.quantity = cells[@fasteners_spikes_quantity_column_description[1]]
        asset.other_manufacturer = cells[@fasteners_spikes_manufacturer_column_number[1]]
        asset.other_manufacturer_model = cells[@fasteners_spikes_model_column_number[1]]
        asset.manufacture_year = cells[@fasteners_spikes_year_of_construction_column_number[1]]

        type = ComponentSubtype.find_by(parent: component_type, name: cells[@fasteners_spikes_screw_type_column_number[1]])
        asset.component_subtype = type

      elsif component_subtype_name == 'Supports'

        asset.description = cells[@fasteners_support_description_column_number[1]]
        asset.quantity = cells[@fasteners_support_quantity_column_description[1]]
        asset.other_manufacturer = cells[@fasteners_support_manufacturer_column_number[1]]
        asset.other_manufacturer_model = cells[@fasteners_support_model_column_number[1]]
        asset.manufacture_year = cells[@fasteners_support_year_of_construction_column_number[1]]

        type = ComponentSubtype.find_by(parent: component_type, name: cells[@fasteners_support_support_type_column_number[1]])
        asset.component_subtype = type

      end
    elsif component_type.name == 'Field Welds'

      asset.description = cells[@field_welds_description_column_number[1]]
      asset.quantity = cells[@field_welds_quantity_column_description[1]]
      asset.other_manufacturer = cells[@fasteners_support_manufacturer_column_number[1]]
      asset.other_manufacturer_model = cells[@fasteners_support_model_column_number[1]]
      asset.manufacture_year = cells[@fasteners_support_year_of_construction_column_number[1]]

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@field_welds_weld_type_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Joints'
      asset.description = cells[@joints_description_column_number[1]]
      asset.quantity = cells[@joints_quantity_column_description[1]]
      asset.other_manufacturer = cells[@joints_manufacturer_column_number[1]]
      asset.other_manufacturer_model = cells[@joints_model_column_number[1]]
      asset.manufacture_year = cells[@joints_year_of_construction_column_number[1]]

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@joints_joint_type_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Ballast'
      asset.description = cells[@ballast_description_column_number[1]]
      asset.quantity = cells[@ballast_quantity_column_description[1]]
      asset.quantity_unit = cells[@ballast_unit_column_number[1]]
      asset.other_manufacturer = cells[@ballast_manufacturer_column_number[1]]
      asset.other_manufacturer_model = cells[@ballast_model_column_number[1]]
      asset.manufacture_year = cells[@ballast_year_of_construction_column_number[1]]

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@ballast_type_column_number[1]])
      asset.component_subtype = type

    end


    # Lchang provided
    (1..4).each do |grant_purchase_count|
      if cells[eval("@program_#{grant_purchase_count}_column_number")[1]].present? && cells[eval("@percent_#{grant_purchase_count}_column_number")[1]].present?
        grant_purchase = asset.grant_purchases.build
        grant_purchase.sourceable = FundingSource.find_by(name: cells[eval("@program_#{grant_purchase_count}_column_number")[1]])
        grant_purchase.pcnt_purchase_cost = cells[eval("@percent_#{grant_purchase_count}_column_number")[1]].to_i
      end
    end

    asset.purchase_cost = cells[@cost_purchase_column_number[1]]

    asset.purchased_new = cells[@purchased_new_column_number[1]].to_s.upcase == 'YES'
    asset.purchase_date = cells[@purchase_date_column_number[1]]
    asset.contract_num = cells[@contract_purchase_order_column_number[1]]
    asset.contract_type = ContractType.find_by(name: cells[@contract_po_type_column_number[1]])
    vendor_name = cells[@vendor_column_number[1]]
    asset.vendor = Vendor.find_by(name: vendor_name)
    if(vendor_name == 'Other')
      asset.other_vendor = cells[@vendor_other_column_number[1]]
    end

    if(!cells[@warranty_column_number[1]].nil? && cells[@warranty_column_number[1]].to_s.upcase == 'YES')
      asset.has_warranty = cells[@warranty_column_number[1]].to_s.upcase == 'YES'
      asset.warranty_date = cells[@warranty_expiration_date_column_number[1]]
    else
      asset.has_warranty = false
    end

    asset.in_service_date = cells[@in_service_date_column_number[1]]
  end

  def set_events(asset, cells, columns)
    # TODO No Events available for SubComponents

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
    asset = InfrastructureComponent.new
    # Need to set these parameters in order to validate the asset.
    object_key = cells[@asset_id_column_number[1]].split(" : ").last
    transam_asset_parent = TransamAsset.find_by(object_key: object_key)
    infrastructure_parent = Infrastructure.find_by(object_key: object_key)
    parent_infrastructure = PowerSignal.find_by(object_key: object_key)
    asset.parent_id = infrastructure_parent.id
    asset.in_service_date = cells[@in_service_date_column_number[1]]
    asset.depreciation_start_date = asset.in_service_date
    asset.fta_asset_category_id = parent_infrastructure.fta_asset_category_id
    asset.fta_asset_class_id = parent_infrastructure.fta_asset_class_id
    asset.fta_type_id = parent_infrastructure.fta_type_id
    asset.asset_subtype = parent_infrastructure.asset_subtype
    asset.fta_type_type = 'FtaPowerSignalType'
  end

  def get_messages_to_process
    @add_processing_message
  end

  def clear_messages_to_process
    @add_processing_message.clear
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

    @rail_description_column_number = RubyXL::Reference.ref2ind('E2')
    @rail_manufacturer_column_number = RubyXL::Reference.ref2ind('F2')
    @rail_model_column_number = RubyXL::Reference.ref2ind('G2')
    @rail_year_of_manufacture_column_number = RubyXL::Reference.ref2ind('H2')
    @rail_length_column_number = RubyXL::Reference.ref2ind('I2')
    @rail_length_unit_column_number = RubyXL::Reference.ref2ind('J2')
    @rail_weight_column_number = RubyXL::Reference.ref2ind('K2')
    @rail_weight_unit_column_number = RubyXL::Reference.ref2ind('L2')
    @rail_rail_type_column_number = RubyXL::Reference.ref2ind('M2')
    @rail_rail_joining_type_column_number = RubyXL::Reference.ref2ind('N2')

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

  def clear_messages_to_process
    @add_processing_message.clear
  end

end