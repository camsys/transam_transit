class TransitCapitalEquipmentTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  # Define sections
  @@identificaiton_and_classification_column_number = RubyXL::Reference.ref2ind('A1')
  @@characteristics_column_number = RubyXL::Reference.ref2ind('I1')
  @@funding_column_number = RubyXL::Reference.ref2ind('AB1')
  @@procurement_and_purchase_column_number = RubyXL::Reference.ref2ind('AP1')
  @@operations_column_number = RubyXL::Reference.ref2ind('AX1')
  @@registration_and_title_column_number = RubyXL::Reference.ref2ind('BG1')
  @@initial_event_data_column_number = RubyXL::Reference.ref2ind('BM1')
  @@last_known_column_number = RubyXL::Reference.ref2ind('BV1')

  @@agency_column_number              = RubyXL::Reference.ref2ind('A2')
  @@description_column_number         = RubyXL::Reference.ref2ind('B2')
  @@asset_id_column_number            = RubyXL::Reference.ref2ind('C2')
  @@external_id_column_number         = RubyXL::Reference.ref2ind('D2')
  @@class_column_number               = RubyXL::Reference.ref2ind('E2')
  @@type_column_number                = RubyXL::Reference.ref2ind('F2')
  @@subtype_column_number             = RubyXL::Reference.ref2ind('G2')
  @@quantity_column_number            = RubyXL::Reference.ref2ind('H2')
  @@quantity_units_column_number      = RubyXL::Reference.ref2ind('I2')
  @@serial_number_column_number       = RubyXL::Reference.ref2ind('J2')
  @@manufacturer_text_column_number   = RubyXL::Reference.ref2ind('K2')
  @@model_text_column_number          = RubyXL::Reference.ref2ind('L2')
  @@year_of_manufacture_column_number = RubyXL::Reference.ref2ind('M2')
  @@program_1_column_number           = RubyXL::Reference.ref2ind('N2')
  @@percent_1_column_number           = RubyXL::Reference.ref2ind('O2')
  @@program_2_column_number           =	RubyXL::Reference.ref2ind('P2')
  @@percent_2_column_number           = RubyXL::Reference.ref2ind('Q2')
  @@program_3_column_number           = RubyXL::Reference.ref2ind('R2')
  @@percent_3_column_number           = RubyXL::Reference.ref2ind('S2')
  @@program_4_column_number           = RubyXL::Reference.ref2ind('T2')
  @@percent_4_column_number           = RubyXL::Reference.ref2ind('U2')
  @@cost_purchase_column_number       = RubyXL::Reference.ref2ind('V2')
  @@direct_capital_responsibility_column_number = RubyXL::Reference.ref2ind('W2')
  @@purchased_new_column_number                 = RubyXL::Reference.ref2ind('X2')
  @@purchase_date_column_number                 = RubyXL::Reference.ref2ind('Y2')
  @@contract_purchase_order_column_number       = RubyXL::Reference.ref2ind('Z2')
  @@contract_po_type_column_number    = RubyXL::Reference.ref2ind('AA2')
  @@vendor_column_number              = RubyXL::Reference.ref2ind('AB2')
  @@vendor_other_column_number        = RubyXL::Reference.ref2ind('AC2')
  @@warranty_column_number            = RubyXL::Reference.ref2ind('AD2')
  @@warranty_expiration_date_column_number = RubyXL::Reference.ref2ind('AE2')
  @@in_service_date_column_number     = RubyXL::Reference.ref2ind('AF2')
  @@title_number_column_number        = RubyXL::Reference.ref2ind('AG2')
  @@title_owner_column_number         = RubyXL::Reference.ref2ind('AH2')
  @@title_owner_other_column_number   = RubyXL::Reference.ref2ind('AI2')
  @@lienholder_column_number          = RubyXL::Reference.ref2ind('AJ2')
  @@lienholder_other_column_number    = RubyXL::Reference.ref2ind('AK2')
  @@condition_column_number                   = RubyXL::Reference.ref2ind('AL2')
  @@date_last_condition_reading_column_number = RubyXL::Reference.ref2ind('AM2')
  @@rebuild_rehabilitation_total_cost_column_number               = RubyXL::Reference.ref2ind('An2')
  @@rebuild_rehabilitation_extend_useful_life_months_column_number= RubyXL::Reference.ref2ind('AO2')
  @@date_of_rebuild_rehabilitation_column_number= RubyXL::Reference.ref2ind('AP2')
  @@service_status_column_number                = RubyXL::Reference.ref2ind('AQ2')
  @@date_of_last_service_status_column_number   = RubyXL::Reference.ref2ind('AR2')

  def green_label_cells
    green_label_cells = [
        @@agency_column_number,
        @@description_column_number,
        @@asset_id_column_number,
        @@class_column_number,
        @@type_column_number,
        @@subtype_column_number,
        @@quantity_column_number,
        @@quantity_units_column_number,
        @@manufacturer_text_column_number,
        @@model_text_column_number,
        @@year_of_manufacture_column_number,
        @@cost_purchase_column_number,
        @@direct_capital_responsibility_column_number,
        @@purchased_new_column_number,
        @@in_service_date_column_number,
        @@service_status_column_number,
        @@date_of_last_service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
        @@external_id_column_number,
        @@serial_number_column_number,
        @@program_1_column_number,
        @@percent_1_column_number,
        @@program_2_column_number,
        @@percent_2_column_number,
        @@program_3_column_number,
        @@percent_3_column_number,
        @@program_4_column_number,
        @@percent_4_column_number,
        @@purchase_date_column_number,
        @@contract_purchase_order_column_number,
        @@contract_po_type_column_number,
        @@vendor_column_number,
        @@warranty_column_number,
        @@warranty_expiration_date_column_number,
        @@title_number_column_number,
        @@title_owner_column_number,
        @@lienholder_column_number,
        @@condition_column_number,
        @@date_last_condition_reading_column_number,
        @@rebuild_rehabilitation_total_cost_column_number,
        @@rebuild_rehabilitation_extend_useful_life_months_column_number,
        @@date_of_rebuild_rehabilitation_column_number
    ]
  end

  def grey_label_cells
    grey_label_cells = [
        @@vendor_other_column_number,
        @@title_owner_other_column_number,
        @@lienholder_other_column_number
    ]
  end

  def setup_instructions()
    instructions = [
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        '• Asset IDs and Row Names are frozen to assist in scrolling through the table',
        "• For Program/Pcnt: The system's front-end is configured to add as many combination values as needed. We have provided you with four values for each.",
        '• Contract/Purchase Order (PO) # and Contract / PO Type can additionally be customized to have multiple values. This field is meant to contain different types of Contract/PO types. If applicable, select the value that applies best.'
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


    # sheet[1][0].change_row_fill(light_green_fill)
    #
    # sheet[identificaiton_and_classification_column_number[0]][identificaiton_and_classification_column_number[1]].value = 'Identification & Classification'
    # sheet.merge_cells(identificaiton_and_classification_column_number[0],identificaiton_and_classification_column_number[1],
    #                   characteristics_column_number[0], (characteristics_column_number[1] -1) )
    #
    #
    # sheet[characteristics_column_number[0]][characteristics_column_number[1]].value = 'Characteristics'
    # sheet.merge_cells(characteristics_column_number[0],characteristics_column_number[1],
    #                   funding_column_number[0], (funding_column_number[1] -1) )
    #
    # sheet[funding_column_number[0]][funding_column_number[1]].value = 'Funding'
    # sheet.merge_cells(funding_column_number[0],funding_column_number[1],
    #                   procurement_and_purchase_column_number[0], (procurement_and_purchase_column_number[1] -1) )
    #
    # sheet[procurement_and_purchase_column_number[0]][procurement_and_purchase_column_number[1]].value = 'Procurement & Purchase'
    # sheet.merge_cells(procurement_and_purchase_column_number[0],procurement_and_purchase_column_number[1],
    #                   operations_column_number[0], (operations_column_number[1] -1) )
    #
    #
    # sheet[operations_column_number[0]][operations_column_number[1]].value = 'Operations'
    # sheet.merge_cells(operations_column_number[0],operations_column_number[1],
    #                   registration_and_title_column_number[0], (registration_and_title_column_number[1] -1) )
    #
    #
    # sheet[registration_and_title_column_number[0]][registration_and_title_column_number[1]].value = 'Registration & Title'
    # sheet.merge_cells(registration_and_title_column_number[0],registration_and_title_column_number[1],
    #                   initial_event_data_column_number[0], (initial_event_data_column_number[1] -1) )
    #
    #
    # sheet[initial_event_data_column_number[0]][initial_event_data_column_number[1]].value = 'Initial Event Data'
    # sheet.merge_cells(initial_event_data_column_number[0],initial_event_data_column_number[1],
    #                   last_known_column_number[0], (last_known_column_number[1] -1) )
    #
    #
    #
    # worksheet.change_column_fill(gross_vehicle_weight_column_number[], grey_fill)
    #
    # worksheet.change_column_fill(@@gross_vehicle_weight_column_number[], grey_fill)
    #
    # sheet[0][0].change_row_fill(dark_green_fill)

    # TODO I almost want to make a class that is just all of these column definitions. Then the builder classes are just a list of calls to make up what is needed
    unless org
      template.add_column(sheet, 'Agency', 'Identification & Classification', {name: 'required_string'}, {
          :type => :list,
          :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
          :showErrorMessage => true,
          :errorTitle => 'Wrong input',
          :error => 'Select a value from the list',
          :errorStyle => :stop,
          :showInputMessage => true,
          :promptTitle => 'Organization',
          :prompt => 'Only values in the list are allowed'
      })
    end

    template.add_column(sheet, 'Description', 'Identification & Classification', {name: 'required_string'}, {
        :type => :textLength,
        :operator => :equal,
        :formula1 => '17',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Text length must be equal to 17',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Description',
        :prompt => 'Text length must be equal to 17'})

    template.add_column(sheet, 'Asset ID', 'Identification & Classification', {name: 'required_string'}, {
        :type => :custom,
        :formula1 => "AND(EXACT(UPPER(#{org.present? ? 'B' : 'C'}3),#{org.present? ? 'B' : 'C'}3),LEN(#{org.present? ? 'B' : 'C'}3)&lt;13)",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Not uppercase or too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Tag',
        :prompt => 'Text length must be uppercase and less than or equal to 12'})

    template.add_column(sheet, 'External ID', 'Identification & Classification', {name: 'recommended_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '32',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'External ID',
        :prompt => 'Text length must be less than ar equal to 32'})

    template.add_column(sheet, 'Class', 'Identification & Classification', {name: 'required_string'}, {
        :type => :textLength,
        :formula1 => "lists!#{template.get_lookup_cells('fta_asset_classes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'
    })

    template.add_column(sheet, 'Type', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('revenue_vehicle_types')}",
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

    template.add_column(sheet, 'Quantity', 'Characteristics', {name: 'required_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Quantity Units', 'Characteristics', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Quantity Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Serial Number', 'Characteristics', {name: 'recommended_integer'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Serial Number',
        :prompt => 'Text length must be less than ar equal to 128'})

    template.add_column(sheet, "Manufacturer", 'Characteristics', {name: 'required_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Other Model',
        :prompt => 'Text length must be less than ar equal to 128'})

    template.add_column(sheet, "Model", 'Characteristics', {name: 'required_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Chassis Other',
        :prompt => 'Text length must be less than ar equal to 128'})

    template.add_column(sheet, 'Year of Manufacture', 'Characteristics', {name: 'required_string'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%Y"),
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
        :prompt => 'Only values in the list are allowed'}, 'recommended_values', ['NO'])

    template.add_column(sheet, 'Pcnt #2', 'Funding', {name: 'fta_pcnt'}, {
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
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Program #4',
        :prompt => 'Only values in the list are allowed'}, 'recommended_values', ['NO'])

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

    template.add_column(sheet, 'Purchase Date', 'Procurement & Purchase', {name: 'recommended_date'}, {
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


    template.add_column(sheet, 'Contract/Purchase Order (PO) #', 'Procurement & Purchase', {name: 'recommended_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '',
        :prompt => 'Text length must be less than ar equal to 128'})

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

    template.add_column(sheet, 'Vendor (Other)', 'Procurement & Purchase', {name: 'other_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '',
        :prompt => 'Text length must be less than ar equal to 128'})

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

    template.add_column(sheet, 'Title  #', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '32',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title  #',
        :prompt => 'Text length must be less than ar equal to 32'})

    template.add_column(sheet, 'Title Owner', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Title Owner',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Title Owner Other', 'Registration & Title', {name: 'other_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '',
        :prompt => 'Text length must be less than ar equal to 128'})

    template.add_column(sheet, 'Lienholder', 'Registration & Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Lienholder',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Lienholder (Other)', 'Registration & Title', {name: 'other_string'}, {
        :type => :textLength,
        :operator => :lessThanOrEqual,
        :formula1 => '128',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Too long text length',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '',
        :prompt => 'Text length must be less than ar equal to 128'})

    template.add_column(sheet, 'Condition', 'Purchase', {name: 'recommended_integer'}, {
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

    template.add_column(sheet, 'Rebuild / Rehabilitation Total Cost', 'Initial Event Data', {name: 'recommendede_currency'}, {
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

    template.add_column(sheet, 'Service Status', 'Initial Event Data', {name: 'required_date'}, {
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

    # add percentage formatting for default row
    a << {:name => "pcnt", :num_fmt => 9, :bg_color => 'EEA2AD', :alignment => { :horizontal => :left }, :locked => false }

    a.flatten
  end

  def column_widths
    if @organization
      [20] + [30] + [20] * 48
    else
      [30] + [20] * 49
    end

  end

  def worksheet_name
    'Capital Equipment'
  end

  private

  def initialize(*args)
    super
  end

end