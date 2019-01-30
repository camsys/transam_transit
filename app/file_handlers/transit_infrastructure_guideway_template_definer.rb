class TransitInfrastructureGuidewayTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME


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

    template.add_column(sheet, 'Asset / Segment ID', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'External ID', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Description', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Location', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'From Line', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'From', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'To Line', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'To', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'Unit', 'Identification & Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'From (Location Name)', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'To (Location Name)', 'Identification & Classification', {name: 'recommended_string'})

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
        :formula1 => "lists!#{template.get_lookup_cells('guideway_types')}",
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

    # segment
    template.add_column(sheet, 'Segment Type', 'Identification & Classification', {name: 'required_string'}, {
            :type => :list,
            :formula1 => "lists!#{template.get_lookup_cells('segment_type')}",
            :showErrorMessage => true,
            :errorTitle => 'Wrong input',
            :error => 'Select a value from the list',
            :errorStyle => :stop,
            :showInputMessage => true,
            :promptTitle => 'Asset Subtype',
            :prompt => 'Only values in the list are allowed'})

    # mainline
    template.add_column(sheet, 'Main Line / Division', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('mainline')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Branch Subdivision', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('branch_subdivisions')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Tracks', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Bridge Type', 'Identification & Classification', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('bridge_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Spans', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Number of Decks', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Bridge Type', 'Identification & Classification', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('guideway_crossing')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Length 1', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Length 1 Unit', 'Identification & Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Length 2', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Length 2 Unit', 'Identification & Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Length 3', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Length 3 Unit', 'Identification & Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

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

    template.add_column(sheet, '% Capital Responsibility', 'Funding', {name: 'required_pcnt'}, {
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

    template.add_column(sheet, 'Organization With Shared Capitol Responsibility', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

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

    template.add_column(sheet, 'Service Type (Primary Mode)', 'Operations', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_service_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Type (Primary Mode)',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Nearest City', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'Land Owner', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, "Land Owner (Other)", 'Characteristics', {name: 'other_string'})

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
        :promptTitle => 'In Service Date',
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

    template.add_column(sheet, 'Date of Last Service Status', 'Initial Event Data', {name: 'required_date'}, {
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

    asset.fta_asset_category = FtaAssetCategory.find_by(name: 'Revenue Vehicles')
    asset.serial_number = cells[@vin_column_number[1]]
    asset.asset_tag = cells[@asset_id_column_number[1]]
    asset.external_id = cells[@external_id_column_number[1]]

    asset.fta_asset_class = FtaAssetClass.find_by(name: cells[@class_column_number[1]])
    asset.fta_type = FtaVehicleType.find_by(name: cells[@type_column_number[1]])

    asset_classification =  cells[@subtype_column_number[1]].to_s.split(' - ')
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification[0], asset_type: AssetType.find_by(name: asset_classification[1]))

    asset.esl_category = EslCategory.find_by(name: cells[@estimated_service_life_category_column_number[1]])

    manufacturer_name = cells[@manufacturer_column_number[1]]
    asset.manufacturer = Manufacturer.find_by(name: manufacturer_name, filter: AssetType.find_by(id: asset.asset_subtype.asset_type_id).class_name)
    if(manufacturer_name == "Other")
      asset.other_manufacturer = cells[@manufacturer_other_column_number[1]]
    end
    model_name = cells[@model_column_number[1]]
    asset.manufacturer_model = ManufacturerModel.find_by(name: model_name)
    if(model_name == "Other")
      asset.other_manufacturer_model = cells[@model_other_column_number[1]]
    end
    chassis_name = cells[@chassis_column_number[1]]
    asset.chassis = Chassis.find_by(name: chassis_name)
    if(chassis_name == "Other")
      asset.other_chassis = cells[@chasis_other_column_number[1]]
    end
    asset.manufacture_year = cells[@year_of_manufacture_column_number[1]]
    fuel_type_name = cells[@fuel_type_column_number[1]]
    asset.fuel_type = FuelType.find_by(name: fuel_type_name)

    if(fuel_type_name == "Other")
      asset.other_fuel_type = cells[@fuel_type_other_column_number[1]]
    end


    # asset.dual_fuel_type = DualFuelType.find_by(name: cells[@dual_fuel_type_column_number[1]])


    asset.vehicle_length = cells[@length_column_number[1]]

    length_unit = cells[@length_units_column_number[1]].downcase

    if(length_unit != 'foot' && length_unit != 'inch' && !Uom.valid?(length_unit))
      @add_processing_message <<  [2, 'warning', "Incompatible length provided #{length_unit} defaulting to foot. for vehicle with Asset Tag #{asset.asset_tag}"]
      length_unit = "foot"
    end

    asset.vehicle_length_unit = length_unit
    asset.gross_vehicle_weight = cells[@gross_vehicle_weight_column_number[1]]
    asset.gross_vehicle_weight_unit = "pound"
    asset.seating_capacity = cells[@seating_capacity_column_number[1]]
    asset.standing_capacity = cells[@standing_capacity_column_number[1]]
    asset.ada_accessible = cells[@ada_accessible_column_number[1]].upcase == 'YES'
    asset.wheelchair_capacity = cells[@wheelchair_capacity_column_number[1]]
    lift_ramp_manufacturer = cells[@lift_ramp_manufacturer_column_number[1]]
    asset.ramp_manufacturer = RampManufacturer.find_by(name: lift_ramp_manufacturer)
    if(lift_ramp_manufacturer == "Other")
      asset.other_ramp_manufacturer = cells[@lift_ramp_manufacturer_other_column_number[1]]
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

    asset.fta_funding_type = FtaFundingType.find_by(name: cells[@funding_type_column_number[1]])

    if (cells[@direct_capital_responsibility_column_number[1]].upcase == 'YES')
      asset.pcnt_capital_responsibility = cells[@percent_capital_responsibility_column_number[1]].to_i
    end

    ownership_type_name = cells[@ownership_type_column_number[1]]
    asset.fta_ownership_type = FtaOwnershipType.find_by(name: ownership_type_name)
    if(ownership_type_name == "Other")
      asset.other_ownership_type = cells[@ownership_type_other_column_number[1]]
    end
    asset.purchased_new = cells[@purchased_new_column_number[1]].upcase == 'YES'
    asset.purchase_date = cells[@purchase_date_column_number[1]]
    asset.contract_num = cells[@contract_purchase_order_column_number[1]]
    asset.contract_type = ContractType.find_by(name: cells[@contract_purchase_order_column_number[1]])
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
    asset.primary_fta_service_type = FtaServiceType.find_by(name: cells[@service_type_primary_mode_column_number[1]])

    secondary_mode_type_string = cells[@supports_another_mode_column_number[1]].to_s.split(' - ')[1]
    unless secondary_mode_type_string.nil?
      asset.secondary_fta_mode_type = FtaModeType.find_by(name: secondary_mode_type_string)
    end

    unless cells[@service_type_supports_another_mode_column_number[1]].nil?
      asset.secondary_fta_service_type = FtaServiceType.find_by(name: cells[@service_type_supports_another_mode_column_number[1]])
    end

    asset.dedicated = cells[@dedicated_asset_column_number[1]].upcase == 'YES'
    asset.license_plate = cells[@plate_number_column_number[1]]
    asset.title_number = cells[@title_number_column_number[1]]

    title_owner_name = cells[@title_owner_column_number[1]]
    unless title_owner_name.nil?
      asset.title_ownership_organization = Organization.find_by(name: title_owner_name)
      if(title_owner_name == 'Other')
        asset.other_title_ownership_organization = cells[@title_owner_other_column_number[1]]
      end
    end

    lienholder_name = cells[@lienholder_column_number[1]]
    unless lienholder_name.nil?
      asset.lienholder = Organization.find_by(name: lienholder_name)
      if(lienholder_name == 'Other')
        asset.other_lienholder = cells[@lienholder_other_column_number[1]]
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
    'Revenue Vehicles'
  end

  def set_initial_asset(cells)
    asset = RevenueVehicle.new
    asset_classification =  cells[@subtype_column_number[1]].to_s.split(' - ')
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification[0], asset_type: AssetType.find_by(name: asset_classification[1]))
    asset.asset_tag = cells[@asset_id_column_number[1]]

    asset
  end

  def get_messages_to_process
    @add_processing_message
  end

  private

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
    @external_id_column_number = RubyXL::Reference.ref2ind('C2')
    @description_column_number =  RubyXL::Reference.ref2ind('D2')
    @location_column_number = RubyXL::Reference.ref2ind('E2')
    @line_from_line_column_number = RubyXL::Reference.ref2ind('F2')
    @line_from_from_column_number = RubyXL::Reference.ref2ind('G2')
    @line_to_line_column_number = RubyXL::Reference.ref2ind('H2')
    @line_to_to_column_number = RubyXL::Reference.ref2ind('I2')
    @unit_column_number = RubyXL::Reference.ref2ind('J2')
    @from_location_column_number = RubyXL::Reference.ref2ind('K2')
    @to_location_column_number = RubyXL::Reference.ref2ind('L2')
    @class_column_number = RubyXL::Reference.ref2ind('M2')
    @type_column_number = RubyXL::Reference.ref2ind('N2')
    @subtype_column_number = RubyXL::Reference.ref2ind('O2')
    @segment_type_column_number = RubyXL::Reference.ref2ind('P2')
    @mainline_column_number = RubyXL::Reference.ref2ind('Q2')
    @branch_column_number = RubyXL::Reference.ref2ind('R2')
    @number_of_tracks_column_number = RubyXL::Reference.ref2ind('S2')
    @bridge_type_column_number = RubyXL::Reference.ref2ind('T2')
    @number_of_spans_column_number = RubyXL::Reference.ref2ind('U2')
    @number_of_decks_column_number = RubyXL::Reference.ref2ind('V2')
    @crossing_column_number = RubyXL::Reference.ref2ind('W2')
    @length_1_column_number = RubyXL::Reference.ref2ind('X2')
    @length_unit_1_column_number = RubyXL::Reference.ref2ind('Y2')
    @length_2_column_number = RubyXL::Reference.ref2ind('Z2')
    @length_unit_2_column_number = RubyXL::Reference.ref2ind('AA2')
    @length_3_column_number = RubyXL::Reference.ref2ind('AB2')
    @length_unit_3_column_number = RubyXL::Reference.ref2ind('AC2')
    @direct_capital_responsibility_column_number =	RubyXL::Reference.ref2ind('AD2')
    @percent_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AE2')
    @organization_with_shared_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AF2')
    @priamry_mode_column_number = RubyXL::Reference.ref2ind('AG2')
    @service_type_primary_mode_column_number = RubyXL::Reference.ref2ind('AH2')
    @nearest_city_column_number = RubyXL::Reference.ref2ind('AI2')
    @state_purchase_column_number = RubyXL::Reference.ref2ind('AJ2')
    @land_owner_column_number = RubyXL::Reference.ref2ind('AK2')
    @land_owner_other_column_number = RubyXL::Reference.ref2ind('AL2')
    @infrastructure_owner_column_number = RubyXL::Reference.ref2ind('AM2')
    @infrastructure_owner_other_column_number = RubyXL::Reference.ref2ind('AN2')
    @condition_column_number = RubyXL::Reference.ref2ind('AO2')
    @date_last_condition_reading_column_number = RubyXL::Reference.ref2ind('AP2')
    @service_status_column_number = RubyXL::Reference.ref2ind('AQ2')
    @date_of_last_service_status_column_number = RubyXL::Reference.ref2ind('AR2')
  end


end