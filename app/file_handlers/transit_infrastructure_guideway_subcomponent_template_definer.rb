class TransitInfrastructureGuidewaySubcomponentTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  def setup_instructions()
    instructions = [
        '• Infrastructure - Guideway tab contains a table where users should enter asset data. Users should enter 1 linear track segment per row and 1 attribute per column',
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        # '• Asset IDs and Row Names are frozen to assist in scrolling through the table',
        '• It is recommended that guideway records be entered for each unique Subtype of linear segment of guideway. Each individual Subtype segment can be broken down further by Segment Type, if desired.',
        "• The List of Fields tab displays a table of all the attributes sorted by color (required status)",
        '• Several Identification & Classification fields are configurable by organization and must be updated prior to conducting an initial Infrastructure - Guideway bulk upload. These fields include: Main Line / Division; and Branch / Subdivision.'
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
    template.add_column(sheet, 'Organization', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})


    template.add_column(sheet, 'Asset / Segment ID', 'Identification & Classification', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('guideways_for_subcomponents')}",
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
        :formula1 => "lists!#{template.get_lookup_cells('subcomponents_for_guideways')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Component / Sub-Component',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Surface / Deck', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Surface / Deck', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Surface / Deck Type', 'Characteristics - Surface / Deck', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('surface_deck_component_subtypes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Surface / Deck Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Surface / Deck Materials', 'Characteristics - Surface / Deck', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('superstructure_component_materials')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Surface / Deck Materials',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Superstructure', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Superstructure', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Superstructure Type', 'Characteristics - Superstructure', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('superstructure_component_subtypes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Superstructure Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Superstructure Materials', 'Characteristics - Superstructure', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('superstructure_component_materials')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Superstructure Materials',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Substructure', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Substructure', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Substructure Type', 'Characteristics - Substructure', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('substructure_component_subtypes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Substructure Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Substructure Materials', 'Characteristics - Substructure', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('substructure_component_materials')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Substructure Materials',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Cap Material', 'Characteristics - Substructure', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('infrastructure_cap_materials')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Cap Material',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Foundation', 'Characteristics - Substructure', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('infrastructure_foundations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Foundation',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Quantity', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'recommended_integer'})

    template.add_column(sheet, 'Quantity Unit', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_sub_ballast_quantity_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Thickness', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_thickness_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Sub Ballast Type', 'Characteristics - Track Bed (Sub-Ballast)', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_sub_ballast_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Sub Ballast Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Quantity / Length', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_integer'})

    template.add_column(sheet, 'Quantity Unit', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_blanket_quantity_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Thickness', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_thickness_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Manufacturer', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Track Bed (Blanket)', {name: 'recommended_string'})

    template.add_column(sheet, 'Blanket Type', 'Characteristics - Track Bed (Blanket)', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_blanket_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Blanket Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Track Bed (Subgrade)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Track Bed (Subgrade)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Quantity', 'Characteristics - Track Bed (Subgrade)', {name: 'recommended_integer'})

    template.add_column(sheet, 'Quantity Unit', 'Characteristics - Track Bed (Subgrade)', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_sub_ballast_quantity_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Thickness', 'Characteristics - Track Bed (Subgrade)', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Track Bed (Subgrade)', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_thickness_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Subgrade Type', 'Characteristics - Track Bed (Subgrade)', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_subgrade_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Subgrade Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Culverts', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Culverts', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Length', 'Characteristics - Culverts', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Culverts', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_sub_ballast_quantity_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Spin / Diameter', 'Characteristics - Culverts', {name: 'recommended_integer'})

    template.add_column(sheet, 'Unit', 'Characteristics - Culverts', {name: 'recommended_integer'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_bed_thickness_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Culvert Type', 'Characteristics - Culverts', {name: 'recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('culvert_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Culvert Type',
        :prompt => 'Only values in the list are allowed'})

    #
    #
    template.add_column(sheet, 'Description', 'Characteristics - Perimeter', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Perimeter', {name: 'last_recommended_year'}, {
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

    template.add_column(sheet, 'Manufacturer', 'Characteristics - Culverts', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Culverts', {name: 'recommended_string'})

    template.add_column(sheet, 'Perimeter Type', 'Characteristics - Culverts', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('perimeter_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Perimeter Type',
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
        :promptTitle => 'Vendor',
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
      pane.top_left_cell = RubyXL::Reference.ind2ref(3,5)
      pane.state = :frozen
      pane.y_split = 2
      pane.x_split = 4
      pane.active_pane = :bottom_right
    end
  end

  def set_columns(asset, cells, columns)
    @add_processing_message = []

    asset.fta_asset_category = FtaAssetCategory.find_by(name: 'Infrastructure')

    organization = cells[@agency_column_number[1]]
    asset.organization = Organization.find_by(name: organization)
    asset.asset_tag = cells[@component_id_column_number[1]]
    component_and_subtype = cells[@component_sub_component_column_number[1]].to_s.split(' - ')
    component_subtype_name = component_and_subtype[1]

    component_type = ComponentType.find_by(name: component_and_subtype[0])
    # component_subtype = ComponentSubtype.find_by(name: component_and_subtype[0], parent_id: component_type.id)
    asset.component_type = component_type

    asset.manufacturer_id = Manufacturer.find_by(code: 'ZZZ', filter: 'Equipment').id
    asset.manufacturer_model_id = ManufacturerModel.find_by(name: 'Other').id

    if component_type.name == 'Surface / Deck'
      asset.description = cells[@deck_description_column_number[1]]
      asset.manufacture_year = cells[@fixed_signals_mounting_year_of_construction_column_number[1]]

      asset.component_material = ComponentMaterial.find_by(name: cells[@deck_material_column_number[1]])

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@deck_type_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Superstructure'
      asset.description = cells[@superstructure_description_column_number[1]]
      asset.manufacture_year = cells[@superstructure_year_of_construction_column_number[1]]

      asset.component_material = ComponentMaterial.find_by(name: cells[@superstructure_material_column_number[1]])

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@superstructure_type_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Substructure'
      asset.description = cells[@substructure_description_column_number[1]]
      asset.manufacture_year = cells[@substructure_year_of_construction_column_number[1]]

      asset.component_material = ComponentMaterial.find_by(name: cells[@substructure_material_column_number[1]])

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@substructure_type_column_number[1]])
      asset.component_subtype = type

      cap_material = InfrastructureCapMaterial.find_by(name: cells[@substructure_cap_material_column_number[1]])
      asset.infrastructure_cap_material = cap_material

      foundation = InfrastructureFoundation.find_by(name: cells[@substructure_foundation_column_number[1]])
      asset.infrastructure_foundation = foundation

    elsif component_type.name == 'Track Bed'
        if component_subtype_name == 'Sub-Ballast'

          asset.description = cells[@track_bed_sub_ballast_description_column_number[1]]
          asset.manufacture_year = cells[@track_bed_sub_ballast_year_of_construction_column_number[1]]

          asset.component_material = ComponentMaterial.find_by(name: cells[@substructure_material_column_number[1]])

          asset.quantity = cells[@track_bed_sub_ballast_quantity_column_number[1]]
          asset.quantity_unit = cells[@track_bed_sub_ballast_quantity_unit_column_number[1]]

          asset.infrastructure_measurement = cells[@track_bed_sub_ballast_thickness_column_number[1]]
          asset.infrastructure_measurement_unit = cells[@track_bed_sub_ballast_thickness_unit_column_number[1]]

          type = ComponentSubtype.find_by(parent: component_type, name: cells[@track_bed_sub_ballast_type_column_number[1]])
          asset.component_subtype = type

        elsif component_subtype_name == 'Blanket'

          asset.description = cells[@track_bed_blanket_description_column_number[1]]
          asset.manufacture_year = cells[@track_bed_blanket_year_of_construction_column_number[1]]

          asset.component_material = ComponentMaterial.find_by(name: cells[@substructure_material_column_number[1]])

          asset.quantity = cells[@track_bed_blanket_quantity_column_number[1]]
          asset.quantity_unit = cells[@track_bed_blanket_quantity_unit_column_number[1]]

          asset.infrastructure_measurement = cells[@track_bed_blanket_thickness_column_number[1]]
          asset.infrastructure_measurement_unit = cells[@track_bed_sub_ballast_thickness_unit_column_number[1]]

          asset.other_manufacturer = cells[@track_bed_blanket_manufacturer_column_number[1]]
          asset.other_manufacturer_model = cells[@track_bed_blanket_model_column_number[1]]

          type = ComponentSubtype.find_by(parent: component_type, name: cells[@track_bed_blanket_type_column_number[1]])
          asset.component_subtype = type

        elsif component_subtype_name == 'Subgrade'

          asset.description = cells[@track_bed_subgrade_description_column_number[1]]
          asset.manufacture_year = cells[@track_bed_subgrade_year_of_construction_column_number[1]]

          asset.quantity = cells[@track_bed_subgrade_quantity_column_number[1]]
          asset.quantity_unit = cells[@track_bed_subgrade_quantity_unit_column_number[1]]

          asset.infrastructure_measurement = cells[@track_bed_subgrade_thickness_column_number[1]]
          asset.infrastructure_measurement_unit = cells[@track_bed_subgrade_thickness_unit_column_number[1]]

          type = ComponentSubtype.find_by(parent: component_type, name: cells[@track_bed_subgrade_type_column_number[1]])
          asset.component_subtype = type

        end
    elsif component_type.name == 'Culverts'
      asset.description = cells[@track_bed_culverts_description_column_number[1]]
      asset.manufacture_year = cells[@track_bed_culverts_year_of_construction_column_number[1]]

      asset.infrastructure_diameter = @track_bed_culverts_span_diameter_column_number
      asset.infrastructure_diameter_unit = @track_bed_culverts_span_diameter_unit_column_number

      asset.infrastructure_measurement = cells[@track_bed_culverts_quantity_column_number[1]]
      asset.infrastructure_measurement_unit = cells[@track_bed_culverts_quantity_unit_column_number[1]]

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@track_bed_culverts_type_column_number[1]])
      asset.component_subtype = type

    elsif component_type.name == 'Perimeter'
      asset.description = cells[@perimeter_description_column_number[1]]
      asset.manufacture_year = cells[@perimeter_year_of_construction_column_number[1]]

      asset.other_manufacturer = cells[@perimeter_manufacturer_column_number[1]]
      asset.other_manufacturer_model = cells[@perimeter_model_column_number[1]]

      type = ComponentSubtype.find_by(parent: component_type, name: cells[@deck_type_column_number[1]])
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

    asset.purchased_new = cells[@purchased_new_column_number[1]].upcase == 'YES'
    asset.purchase_date = cells[@purchase_date_column_number[1]]
    asset.contract_num = cells[@contract_purchase_order_column_number[1]]
    asset.contract_type = ContractType.find_by(name: cells[@contract_po_type_column_number[1]])
    vendor_name = cells[@vendor_column_number[1]]
    asset.vendor = Vendor.find_by(name: vendor_name)
    if(vendor_name == 'Other')
      asset.other_vendor = cells[@vendor_other_column_number[1]]
    end

    if(!cells[@warranty_column_number[1]].nil? && cells[@warranty_column_number[1]].upcase == 'YES')
      asset.has_warranty = cells[@warranty_column_number[1]].upcase == 'YES'
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
    'Infra - Guideway Components'
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

    @deck_description_column_number = RubyXL::Reference.ref2ind('E2')
    @deck_year_of_construction_column_number = RubyXL::Reference.ref2ind('F2')
    @deck_type_column_number = RubyXL::Reference.ref2ind('G2')
    @deck_material_column_number = RubyXL::Reference.ref2ind('H2')

    @superstructure_description_column_number = RubyXL::Reference.ref2ind('I2')
    @superstructure_year_of_construction_column_number = RubyXL::Reference.ref2ind('J2')
    @superstructure_type_column_number = RubyXL::Reference.ref2ind('K2')
    @superstructure_material_column_number = RubyXL::Reference.ref2ind('L2')

    @substructure_description_column_number = RubyXL::Reference.ref2ind('M2')
    @substructure_year_of_construction_column_number = RubyXL::Reference.ref2ind('N2')
    @substructure_type_column_number = RubyXL::Reference.ref2ind('O2')
    @substructure_material_column_number = RubyXL::Reference.ref2ind('P2')
    @substructure_cap_material_column_number = RubyXL::Reference.ref2ind('Q2')
    @substructure_foundation_column_number = RubyXL::Reference.ref2ind('R2')

    @track_bed_sub_ballast_description_column_number = RubyXL::Reference.ref2ind('S2')
    @track_bed_sub_ballast_year_of_construction_column_number = RubyXL::Reference.ref2ind('T2')
    @track_bed_sub_ballast_quantity_column_number = RubyXL::Reference.ref2ind('U2')
    @track_bed_sub_ballast_quantity_unit_column_number = RubyXL::Reference.ref2ind('V2')
    @track_bed_sub_ballast_thickness_column_number = RubyXL::Reference.ref2ind('W2')
    @track_bed_sub_ballast_thickness_unit_column_number = RubyXL::Reference.ref2ind('X2')
    @track_bed_sub_ballast_type_column_number = RubyXL::Reference.ref2ind('Y2')

    @track_bed_blanket_description_column_number = RubyXL::Reference.ref2ind('Z2')
    @track_bed_blanket_year_of_construction_column_number = RubyXL::Reference.ref2ind('AA2')
    @track_bed_blanket_quantity_column_number = RubyXL::Reference.ref2ind('AB2')
    @track_bed_blanket_quantity_unit_column_number = RubyXL::Reference.ref2ind('AC2')
    @track_bed_blanket_thickness_column_number = RubyXL::Reference.ref2ind('AD2')
    @track_bed_blanket_thickness_unit_column_number = RubyXL::Reference.ref2ind('AE2')
    @track_bed_blanket_manufacturer_column_number = RubyXL::Reference.ref2ind('AF2')
    @track_bed_blanket_model_column_number = RubyXL::Reference.ref2ind('AG2')
    @track_bed_blanket_type_column_number = RubyXL::Reference.ref2ind('AH2')

    @track_bed_subgrade_description_column_number = RubyXL::Reference.ref2ind('AI2')
    @track_bed_subgrade_year_of_construction_column_number = RubyXL::Reference.ref2ind('AJ2')
    @track_bed_subgrade_quantity_column_number = RubyXL::Reference.ref2ind('AK2')
    @track_bed_subgrade_quantity_unit_column_number = RubyXL::Reference.ref2ind('AL2')
    @track_bed_subgrade_thickness_column_number = RubyXL::Reference.ref2ind('AM2')
    @track_bed_subgrade_thickness_unit_column_number = RubyXL::Reference.ref2ind('AN2')
    @track_bed_subgrade_type_column_number = RubyXL::Reference.ref2ind('AO2')

    @track_bed_culverts_description_column_number = RubyXL::Reference.ref2ind('AP2')
    @track_bed_culverts_year_of_construction_column_number = RubyXL::Reference.ref2ind('AQ2')
    @track_bed_culverts_quantity_column_number = RubyXL::Reference.ref2ind('AR2')
    @track_bed_culverts_quantity_unit_column_number = RubyXL::Reference.ref2ind('AS2')
    @track_bed_culverts_span_diameter_column_number = RubyXL::Reference.ref2ind('AT2')
    @track_bed_culverts_span_diameter_unit_column_number = RubyXL::Reference.ref2ind('AU2')
    @track_bed_culverts_type_column_number = RubyXL::Reference.ref2ind('AV2')

    @perimeter_description_column_number = RubyXL::Reference.ref2ind('AW2')
    @perimeter_year_of_construction_column_number = RubyXL::Reference.ref2ind('AX2')
    @perimeter_manufacturer_column_number = RubyXL::Reference.ref2ind('AY2')
    @perimeter_model_column_number = RubyXL::Reference.ref2ind('AZ2')
    @deck_type_column_number = RubyXL::Reference.ref2ind('BA2')

    @program_1_column_number = RubyXL::Reference.ref2ind('BB2')
    @percent_1_column_number = RubyXL::Reference.ref2ind('BC2')
    @program_2_column_number =	RubyXL::Reference.ref2ind('BD2')
    @percent_2_column_number = RubyXL::Reference.ref2ind('BE2')
    @program_3_column_number = RubyXL::Reference.ref2ind('BF2')
    @percent_3_column_number = RubyXL::Reference.ref2ind('BG2')
    @program_4_column_number = RubyXL::Reference.ref2ind('BH2')
    @percent_4_column_number = RubyXL::Reference.ref2ind('BI2')
    @cost_purchase_column_number = RubyXL::Reference.ref2ind('BJ2')

    @purchased_new_column_number = RubyXL::Reference.ref2ind('BK2')
    @purchase_date_column_number = RubyXL::Reference.ref2ind('BL2')
    @contract_purchase_order_column_number = RubyXL::Reference.ref2ind('BM2')
    @contract_po_type_column_number = RubyXL::Reference.ref2ind('BN2')
    @vendor_column_number = RubyXL::Reference.ref2ind('BO2')
    @vendor_other_column_number = RubyXL::Reference.ref2ind('BP2')
    @warranty_column_number = RubyXL::Reference.ref2ind('BQ2')
    @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('BR2')
    @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('BR2')
    @in_service_date_column_number = RubyXL::Reference.ref2ind('BS2')

  end


end