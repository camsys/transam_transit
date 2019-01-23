class TransitFacilitySubComponentTemplateDefiner
  require 'rubyXL'

  def setup_instructions()
    instructions = [
        '• Components & Sub-Components tab contains a table where users select a primary facility and enter the Components and Sub-Components associated with the selected primary facility. Users should enter 1 component or sub-component per row and 1 attribute per column. Each primary facility can be broken down into individual components and sub-components.',
        '• Only 1 Component or 1 Subcomponent can be added per row, but not both. The system will be unable to process a row that has comonent and subcomponent columns are both set',
        '• Class, Type and Subtype are set by the selection of the Facility Name',
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        '• Identifying information and Row Names are frozen to assist in scrolling through the table.',
        "• For Program/Pcnt: The system's front-end is configured to add as many combination values as needed. We have provided you with four values for each.",
        '• Contract/Purchase Order (PO) # and Contract / PO Type can additionally be customized to have multiple values. This field is meant to contain different types of Contract/PO types. If applicable, select the value that',
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

    template.add_column(sheet, 'Asset ID', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'Facility Name', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'External ID', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Description', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Facility Categorization', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('facility_sub_component_categorizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Facility Categorization (Component)', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('facility_component_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Facility Categorization (Sub-Component)', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('facility_component_sub_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Parent Facility', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('facilities')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Quantity', 'Identification & Classification', {name: 'recommended_integer'}, {
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

    template.add_column(sheet, 'Quantity Units', 'Identification & Classification', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Serial #/Inventory ID', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, "Manufacturer", 'Characteristics', {name: 'recommended_string'})

    template.add_column(sheet, "Model", 'Characteristics', {name: 'recommended_string'})

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
        :promptTitle => 'Manufacture Year',
        :prompt => "Only values greater than #{earliest_date.year}"}, 'default_values', [Date.today.year.to_s])

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

    organization = cells[@agency_column_number[1]]
    asset.organization = Organization.find_by(name: organization)
    asset.asset_tag = cells[@asset_id_column_number[1]]
    asset.facility_name = cells[@facility_name_column_number[1]]
    asset.external_id = cells[@external_id_column_number[1]]
    asset.description = cells[@description_column_number[1]]



    # @facility_categorization_column_number = RubyXL::Reference.ref2ind('F2')
    # @facility_categorization_component_column_number = RubyXL::Reference.ref2ind('G2')
    # @facility_categorization_subcomponent_column_number = RubyXL::Reference.ref2ind('H2')
    # @parent_facility_column_number = RubyXL::Reference.ref2ind('I2')
    # @quantity_column_number = RubyXL::Reference.ref2ind('J2')
    # @quantity_units_column_number = RubyXL::Reference.ref2ind('K2')
    # @quantity_units_column_number = RubyXL::Reference.ref2ind('K2')
    # @serial_number_column_number = RubyXL::Reference.ref2ind('L2')
    # @manufacturer_column_number = RubyXL::Reference.ref2ind('M2')
    # @model_column_number = RubyXL::Reference.ref2ind('N2')
    # @year_built_column_number = RubyXL::Reference.ref2ind('O2')
    # @program_1_column_number = RubyXL::Reference.ref2ind('P2')
    # @percent_1_column_number = RubyXL::Reference.ref2ind('Q2')
    # @program_2_column_number =	RubyXL::Reference.ref2ind('R2')
    # @percent_2_column_number = RubyXL::Reference.ref2ind('S2')
    # @program_3_column_number = RubyXL::Reference.ref2ind('T2')
    # @percent_3_column_number = RubyXL::Reference.ref2ind('U2')
    # @program_4_column_number = RubyXL::Reference.ref2ind('V2')
    # @percent_4_column_number = RubyXL::Reference.ref2ind('W2')
    # @cost_purchase_column_number = RubyXL::Reference.ref2ind('X2')
    # @direct_capital_responsibility_column_number = RubyXL::Reference.ref2ind('Y2')
    # @percent_capital_responsibility_column_number = RubyXL::Reference.ref2ind('Z2')
    # @purchased_new_column_number = RubyXL::Reference.ref2ind('AA2')
    # @purchase_date_column_number = RubyXL::Reference.ref2ind('AB2')
    # @contract_po_type_column_number = RubyXL::Reference.ref2ind('AC2')
    # @contract_purchase_order_column_number = RubyXL::Reference.ref2ind('AD2')
    # @warranty_column_number = RubyXL::Reference.ref2ind('AE2')
    # @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('AF2')
    # @condition_column_number = RubyXL::Reference.ref2ind('AG2')
    # @date_last_condition_reading_column_number = RubyXL::Reference.ref2ind('AH2')
    # @rebuild_rehabilitation_total_cost_column_number = RubyXL::Reference.ref2ind('AI2')
    # @rebuild_rehabilitation_extend_useful_life_months_column_number = RubyXL::Reference.ref2ind('AJ2')
    # @date_of_rebuild_rehabilitation_column_number = RubyXL::Reference.ref2ind('AK2')
    # @service_status_column_number = RubyXL::Reference.ref2ind('AL2')
    # @date_of_last_service_status_column_number = RubyXL::Reference.ref2ind('AM2')

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

    length_unit = cells[@length_units_column_number[1]].upcase

    if(length_unit != 'FEET' || length_unit != 'INCHES' || !Uom.valid?(length_unit))
      @add_processing_message <<  [2, 'warning', "Incompatible length provided #{length_unit} defaulting to FEET. for vehicle with Asset Tag #{asset.asset_tag}"]
      length_unit = "FEET"
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
    asset.secondary_fta_mode_types = FtaModeType.where(name: secondary_mode_type_string)
    # TODO figure this out
    # asset.additional_fta_service_type = FtaServiceType.find_by(name: cells[@service_type_supports_another_mode_column_number])
    asset.dedicated = cells[@dedicated_asset_column_number[1]].upcase == 'YES'
    asset.license_plate = cells[@plate_number_column_number[1]]
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
    'Facility Components'
  end

  def set_initial_asset(cells)
    asset = TransitComponent.new
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
        @facility_categorization_component_column_number,
        @facility_categorization_subcomponent_column_number,
        @parent_facility_column_number,
        @year_built_column_number,
        @cost_purchase_column_number,
        @direct_capital_responsibility_column_number,
        @percent_capital_responsibility_column_number,
        @purchased_new_column_number,
        @purchase_date_column_number,
        @service_status_column_number,
        @date_of_last_service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
        @external_id_column_number,
        @description_column_number,
        @quantity_column_number,
        @quantity_units_column_number,
        @quantity_units_column_number,
        @serial_number_column_number,
        @manufacturer_column_number,
        @model_column_number,
        @program_1_column_number,
        @percent_1_column_number,
        @program_2_column_number,
        @percent_2_column_number,
        @program_3_column_number,
        @percent_3_column_number,
        @program_4_column_number,
        @percent_4_column_number,
        @contract_po_type_column_number,
        @contract_purchase_order_column_number,
        @warranty_column_number,
        @warranty_expiration_date_column_number,
        @condition_column_number,
        @date_last_condition_reading_column_number,
        @rebuild_rehabilitation_total_cost_column_number,
        @rebuild_rehabilitation_extend_useful_life_months_column_number,
        @date_of_rebuild_rehabilitation_column_number
    ]
  end

  def grey_label_cells
    grey_label_cells = [ ]
  end

  private

  def initialize(*args)
    super

    # Define sections
    @identificaiton_and_classification_column_number = RubyXL::Reference.ref2ind('A1')
    @characteristics_column_number = RubyXL::Reference.ref2ind('M1')
    @funding_column_number = RubyXL::Reference.ref2ind('P1')
    @procurement_and_purchase_column_number = RubyXL::Reference.ref2ind('AA1')
    @initial_event_data_column_number = RubyXL::Reference.ref2ind('AG1')

    # Define light green columns
    @agency_column_number = RubyXL::Reference.ref2ind('A2')
    @asset_id_column_number = RubyXL::Reference.ref2ind('B2')
    @facility_name_column_number = RubyXL::Reference.ref2ind('C2')
    @external_id_column_number = RubyXL::Reference.ref2ind('D2')
    @description_column_number = RubyXL::Reference.ref2ind('E2')
    # @ntd_id_column_number =  RubyXL::Reference.ref2ind('E2')
    @facility_categorization_column_number = RubyXL::Reference.ref2ind('F2')
    @facility_categorization_component_column_number = RubyXL::Reference.ref2ind('G2')
    @facility_categorization_subcomponent_column_number = RubyXL::Reference.ref2ind('H2')
    @parent_facility_column_number = RubyXL::Reference.ref2ind('I2')
    @quantity_column_number = RubyXL::Reference.ref2ind('J2')
    @quantity_units_column_number = RubyXL::Reference.ref2ind('K2')
    @quantity_units_column_number = RubyXL::Reference.ref2ind('K2')
    @serial_number_column_number = RubyXL::Reference.ref2ind('L2')
    @manufacturer_column_number = RubyXL::Reference.ref2ind('M2')
    @model_column_number = RubyXL::Reference.ref2ind('N2')
    @year_built_column_number = RubyXL::Reference.ref2ind('O2')
    @program_1_column_number = RubyXL::Reference.ref2ind('P2')
    @percent_1_column_number = RubyXL::Reference.ref2ind('Q2')
    @program_2_column_number =	RubyXL::Reference.ref2ind('R2')
    @percent_2_column_number = RubyXL::Reference.ref2ind('S2')
    @program_3_column_number = RubyXL::Reference.ref2ind('T2')
    @percent_3_column_number = RubyXL::Reference.ref2ind('U2')
    @program_4_column_number = RubyXL::Reference.ref2ind('V2')
    @percent_4_column_number = RubyXL::Reference.ref2ind('W2')
    @cost_purchase_column_number = RubyXL::Reference.ref2ind('X2')
    @direct_capital_responsibility_column_number = RubyXL::Reference.ref2ind('Y2')
    @percent_capital_responsibility_column_number = RubyXL::Reference.ref2ind('Z2')
    @purchased_new_column_number = RubyXL::Reference.ref2ind('AA2')
    @purchase_date_column_number = RubyXL::Reference.ref2ind('AB2')
    @contract_po_type_column_number = RubyXL::Reference.ref2ind('AC2')
    @contract_purchase_order_column_number = RubyXL::Reference.ref2ind('AD2')
    @warranty_column_number = RubyXL::Reference.ref2ind('AE2')
    @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('AF2')
    @condition_column_number = RubyXL::Reference.ref2ind('AG2')
    @date_last_condition_reading_column_number = RubyXL::Reference.ref2ind('AH2')
    @rebuild_rehabilitation_total_cost_column_number = RubyXL::Reference.ref2ind('AI2')
    @rebuild_rehabilitation_extend_useful_life_months_column_number = RubyXL::Reference.ref2ind('AJ2')
    @date_of_rebuild_rehabilitation_column_number = RubyXL::Reference.ref2ind('AK2')
    @service_status_column_number = RubyXL::Reference.ref2ind('AL2')
    @date_of_last_service_status_column_number = RubyXL::Reference.ref2ind('AM2')

  end


end