class TransitInfrastructurePowerSignalSubcomponentTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME


  def green_label_cells
    green_label_cells = [
      @agency_column_number,
      @vin_column_number,
      @asset_id_column_number,
      @class_column_number,
      @type_column_number,
      @subtype_column_number,
      @estimated_service_life_category_column_number,
      @manufacturer_column_number,
      @model_column_number,
      @chassis_column_number,
      @year_of_manufacture_column_number,
      @fuel_type_column_number,
      @length_column_number,
      @length_units_column_number,
      @seating_capacity_column_number,
      @standing_capacity_column_number,
      @ada_accessible_column_number,
      @wheelchair_capacity_column_number,
      @cost_purchase_column_number,
      @funding_type_column_number,
      @direct_capital_responsibility_column_number,
      @percent_capital_responsibility_column_number,
      @ownership_type_column_number,
      @purchased_new_column_number,
      @in_service_date_column_number,
      @priamry_mode_column_number,
      @service_type_primary_mode_column_number,
      @dedicated_asset_column_number,
      @service_status_column_number,
      @date_of_last_service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
      @external_id_column_number,
      @gross_vehicle_weight_column_number,
      @lift_ramp_manufacturer_column_number,
      @program_1_column_number,
      @percent_1_column_number,
      @program_2_column_number,
      @percent_2_column_number,
      @program_3_column_number,
      @percent_3_column_number,
      @program_4_column_number,
      @percent_4_column_number,
      @purchase_date_column_number,
      @contract_purchase_order_column_number,
      @contract_po_type_column_number,
      @vendor_column_number,
      @warranty_column_number,
      @warranty_expiration_date_column_number,
      @operator_column_number,
      @features_column_number,
      @supports_another_mode_column_number,
      @service_type_supports_another_mode_column_number,
      @plate_number_column_number,
      @title_number_column_number,
      @title_owner_column_number,
      @lienholder_column_number,
      @odometer_reading_column_number,
      @date_last_odometer_reading_column_number,
      @condition_column_number,
      @date_last_condition_reading_column_number,
      @rebuild_rehabilitation_total_cost_column_number,
      @rebuild_rehabilitation_extend_useful_life_months_column_number,
      @rebuild_rehabilitation_extend_useful_life_miles_column_number,
      @date_of_rebuild_rehabilitation_column_number,
    ]
  end

  def grey_label_cells
    grey_label_cells = [
        @manufacturer_other_column_number,
        @model_other_column_number,
        @chasis_other_column_number,
        @fuel_type_other_column_number,
        @dual_fuel_type_other_column_number,
        @lift_ramp_manufacturer_other_column_number,
        @ownership_type_other_column_number,
        @vendor_other_column_number,
        @operator_other_column_number,
        @title_owner_other_column_number,
        @lienholder_other_column_number,
    ]
  end

  def setup_instructions()
    instructions = [
        '• Components & Sub-Componentstab contains a table where users should enter asset data. Users should enter 1 component / sub-component asset selection per row and 1 attribute per column',
        '• For Characteristics: There are three unique Component / Sub-Component Types in the Characteristics section - Fixed Signals-Signals, Fixed Signals-Mounting, and Signal House. Only data for a single component / sub-component should be entered per row. i.e. if you wish to enter data for Fixed Signals-Signals and Fixed Signals-Mounting, this requires two separate rows of data entry. In addition, if you wish to enter three types of Signal House records, this requires three separate rows of data entry.',
        '• For Characteristics: Not all components and sub-components are applicable to all forms of Power & Signal segments. i.e. some lines may not included signal houses.',
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
        :formula1 => "lists!#{template.get_lookup_cells('power_signals_for_subcomponents')}",
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
        :formula1 => "lists!#{template.get_lookup_cells('subcomponents_for_powersignal')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Component / Sub-Component',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Fixed Signals (Signals)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Fixed Signals (Signals)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Manufacturer', 'Characteristics - Fixed Signals (Signals)', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Fixed Signals (Signals)', {name: 'recommended_string'})

    template.add_column(sheet, 'Signal Type', 'Characteristics - Fixed Signals (Signals)', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fixed_signal_signal_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Signal Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Fixed Signals (Mounting)', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Fixed Signals (Mounting)', {name: 'recommended_year'}, {
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

    template.add_column(sheet, 'Manufacturer', 'Characteristics - Fixed Signals (Mounting)', {name: 'recommended_string'})
    template.add_column(sheet, 'Model', 'Characteristics - Fixed Signals (Mounting)', {name: 'recommended_string'})

    template.add_column(sheet, 'Mounting Type', 'Characteristics - Fixed Signals (Mounting)', {name: 'last_recommended_year'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fixed_signal_mounting_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Mounting Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Description', 'Characteristics - Signal House', {name: 'recommended_string'})

    template.add_column(sheet, 'Year of Construction', 'Characteristics - Signal House', {name: 'last_recommended_year'}, {
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

    organization = cells[@subtype_column_number[1].to_s.split(':').last]
    asset.organization = Organization.find_by(name: organization)

    asset.asset_tag = cells[@component_id_column_number[1]]
    component_and_subtype = cells[@component_sub_component_column_number[1]].to_s.split(' - ')
    component_subtype_name = component_and_subtype[1]

    component_type = ComponentType.find_by(name: component_and_subtype[0])
    # component_subtype = ComponentSubtype.find_by(name: component_and_subtype[0], parent_id: component_type.id)
    asset.component_type = component_type

    asset.manufacturer_id = Manufacturer.find_by(code: 'ZZZ', filter: 'Equipment').id
    asset.manufacturer_model_id = ManufacturerModel.find_by(name: 'Other').id

    if component_type.name == 'Fixed Signals'
      if component_subtype_name == 'Signals'

        asset.description = cells[@fixed_signals_signals_description_column_number[1]]
        asset.manufacture_year = cells[@fixed_signals_signals_year_of_construction_column_number[1]]
        asset.other_manufacturer = cells[@fixed_signals_signals_manufacturer_column_number[1]]
        asset.other_manufacturer_model = cells[@fixed_signals_signals_model_column_number[1]]

        type = ComponentSubtype.find_by(parent: component_type, name: cells[@fixed_signals_signals_signal_type_column_number[1]])
        asset.component_subtype = type

      elsif component_subtype_name == 'Mounting'

        asset.description = cells[@fixed_signals_mounting_description_column_number[1]]
        asset.manufacture_year = cells[@fixed_signals_mounting_year_of_construction_column_number[1]]
        asset.other_manufacturer = cells[@fixed_signals_mounting_manufacturer_column_number[1]]
        asset.other_manufacturer_model = cells[@fixed_signals_mounting_model_column_number[1]]

        type = ComponentSubtype.find_by(parent: component_type, name: cells[@fixed_signals_mounting_mounting_type_column_number[1]])
        asset.component_subtype = type

      end
    elsif component_type.name == 'Signal House'
      asset.description = cells[@signal_house_description_column_number[1]]
      asset.manufacture_year = cells[@signal_house_year_of_construction_column_number[1]]
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

    return asset
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
    'Infra - Power.Signal Components'
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
    @characteristics_column_number = RubyXL::Reference.ref2ind('I1')
    @funding_column_number = RubyXL::Reference.ref2ind('AB1')
    @procurement_and_purchase_column_number = RubyXL::Reference.ref2ind('AP1')
    @operations_column_number = RubyXL::Reference.ref2ind('AX1')
    @registration_and_title_column_number = RubyXL::Reference.ref2ind('BG1')
    @initial_event_data_column_number = RubyXL::Reference.ref2ind('BM1')
    @last_known_column_number = RubyXL::Reference.ref2ind('BV1')

    # Define light green columns
    @agency_column_number = RubyXL::Reference.ref2ind('A2')
    @asset_id_column_number = RubyXL::Reference.ref2ind('B2')
    @component_id_column_number = RubyXL::Reference.ref2ind('C2')
    @component_sub_component_column_number = RubyXL::Reference.ref2ind('D2')

    @fixed_signals_signals_description_column_number = RubyXL::Reference.ref2ind('E2')
    @fixed_signals_signals_year_of_construction_column_number = RubyXL::Reference.ref2ind('F2')
    @fixed_signals_signals_manufacturer_column_number = RubyXL::Reference.ref2ind('G2')
    @fixed_signals_signals_model_column_number = RubyXL::Reference.ref2ind('H2')
    @fixed_signals_signals_signal_type_column_number = RubyXL::Reference.ref2ind('I2')

    @fixed_signals_mounting_description_column_number = RubyXL::Reference.ref2ind('J2')
    @fixed_signals_mounting_year_of_construction_column_number = RubyXL::Reference.ref2ind('K2')
    @fixed_signals_mounting_manufacturer_column_number = RubyXL::Reference.ref2ind('L2')
    @fixed_signals_mounting_model_column_number = RubyXL::Reference.ref2ind('M2')
    @fixed_signals_mounting_mounting_type_column_number = RubyXL::Reference.ref2ind('N2')

    @signal_house_description_column_number = RubyXL::Reference.ref2ind('O2')
    @signal_house_year_of_construction_column_number = RubyXL::Reference.ref2ind('P2')

    @program_1_column_number = RubyXL::Reference.ref2ind('Q2')
    @percent_1_column_number = RubyXL::Reference.ref2ind('R2')
    @program_2_column_number =	RubyXL::Reference.ref2ind('S2')
    @percent_2_column_number = RubyXL::Reference.ref2ind('T2')
    @program_3_column_number = RubyXL::Reference.ref2ind('U2')
    @percent_3_column_number = RubyXL::Reference.ref2ind('V2')
    @program_4_column_number = RubyXL::Reference.ref2ind('W2')
    @percent_4_column_number = RubyXL::Reference.ref2ind('X2')
    @cost_purchase_column_number = RubyXL::Reference.ref2ind('Y2')

    @purchased_new_column_number = RubyXL::Reference.ref2ind('Z2')
    @purchase_date_column_number = RubyXL::Reference.ref2ind('AA2')
    @contract_purchase_order_column_number = RubyXL::Reference.ref2ind('AB2')
    @contract_po_type_column_number = RubyXL::Reference.ref2ind('AC2')
    @vendor_column_number = RubyXL::Reference.ref2ind('AD2')
    @vendor_other_column_number = RubyXL::Reference.ref2ind('AE2')
    @warranty_column_number = RubyXL::Reference.ref2ind('AF2')
    @warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('AG2')
    @in_service_date_column_number = RubyXL::Reference.ref2ind('AH2')

  end


end