class InventoryUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  protected

  def add_rows(sheet)
    assets = @assets.includes(:asset_type, :asset_subtype, :service_status_type).order(:organization_id,:asset_type_id)
    assets.each do |asset|
      row_data  = []
      row_data << asset.object_key
      row_data << asset.asset_type.name
      row_data << asset.asset_subtype.name
      row_data << asset.asset_tag
      row_data << asset.external_id
      row_data << asset.description

      row_data << (asset.service_status_type || "-") # prev_service_status
      row_data << nil # current_service_status
      row_data << nil # date

      row_data << asset.reported_condition_rating # Previous Condition
      row_data << nil # Current Condition
      row_data << nil # Date

      if include_mileage_columns?
        row_data << (asset.reported_mileage || "-") # Previous Mileage
        row_data << nil # Current Mileage
        row_data << nil # Date
      end

      sheet.add_row row_data, :types => row_types
    end
  end



  def setup_workbook(workbook)


    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'

    row = []
    @service_types = ServiceStatusType.active.pluck(:name)
    @service_types.each do |x|
      row << x unless x.eql? "Unknown"
    end
    sheet.add_row row
  end


  def post_process(sheet)


    sheet.merge_cells("A1:F1")
    sheet.merge_cells("G1:I1")
    sheet.merge_cells("J1:L1")
    sheet.merge_cells("M1:O1") if include_mileage_columns?

    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    sheet.add_data_validation("H3:H500", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@service_types.size]}$1",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Service Type',
      :prompt => 'Only values in the list are allowed'})

    sheet.add_data_validation("I3:I500", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Status Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    sheet.add_data_validation("K3:K500", {
      :type => :decimal,
      :operator => :between,
      :formula1 => '0.0',
      :formula2 => '5.0',
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Must be between 0.0 and 5.0',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Vehicle Condition',
      :prompt => 'Only values between 0 and 5'})

    sheet.add_data_validation("L3:L500", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    sheet.add_data_validation("N3:N500", {
      :type => :whole,
      :operator => :greaterThan,
      :formula1 => '0',
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Milage must be > 0",
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Vehicle Mileage',
      :prompt => 'Only values greater than 0'})

    sheet.add_data_validation("O3:O500", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :errorTitle => 'Wrong input',
      :errorStyle => :information,
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :showInputMessage => true,
      :promptTitle => 'Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    sheet.sheet_protection.password = "transam"
  end


  def header_rows
   event_row = [
      'Asset',
      '',
      '',
      '',
      '',
      '',
      'Service Status',
      '',
      '',
      'Condition Report',
      '',
      ''
    ]
    if include_mileage_columns?
      event_row.concat([
        'Mileage Update',
        '',
        ''
      ])
    end


    attr_row = [
      'Object Key',
      'Type',
      'Subtype',
      'Tag',
      'External Id',
      'Description',

      'Prev. Service Status',
      'Curr. Service Status',
      'Reporting Date (MM/DD/YYYY)',

      'Prev. Condition',
      'Curr. Condition',
      'Reporting Date (MM/DD/YYYY)',
    ]
    if include_mileage_columns?
      attr_row.concat([
        'Prev. Mileage',
        'Curr. Mileage',
        'Reporting Date (MM/DD/YYYY)',
      ])
    end

    return [event_row, attr_row]
  end

  def column_styles
    col_styles = [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},
      {:name => 'asset_id_col', :column => 4},
      {:name => 'asset_id_col', :column => 5},

      {:name => 'service_status_string_locked',   :column => 6},
      {:name => 'service_status_string',   :column => 7},
      {:name => 'service_status_date',     :column => 8},

      {:name => 'condition_updates_float_locked', :column => 9},
      {:name => 'condition_updates_float', :column => 10},
      {:name => 'condition_updates_date',  :column => 11}

    ]
    if include_mileage_columns?
      col_styles.concat([
        {:name => 'mileage_col_int_locked', :column => 12},
        {:name => 'mileage_col_int', :column => 13},
        {:name => 'mileage_col_date', :column => 14}
      ])
    end
    col_styles
  end

  def row_types
    types = [
      # Asset ID
      :string,
      :string,
      :string,
      :string,
      :string,
      :string,

      #Service Status
      :string,
      :string,
      :date,

      #Condition
      :float,
      :float,
      :date
    ]

    if include_mileage_columns?
      types.concat([
        :integer,
        :integer,
        :date
      ])
    end
    types
  end

  def styles
    a = []
    a << super

    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => true, :alignment => { :horizontal => :left }}

    a << {:name => 'condition_updates_float', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :right } , :locked => false }
    a << {:name => 'condition_updates_float_locked', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :right } , :locked => true }
    a << {:name => 'condition_updates_date', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :right } , :locked => false }

    a << {:name => 'service_status_string', :bg_color => "F2DCDB", :alignment => { :horizontal => :left } , :locked => false }
    a << {:name => 'service_status_string_locked', :bg_color => "F2DCDB", :alignment => { :horizontal => :left } , :locked => true }
    a << {:name => 'service_status_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :right } , :locked => false }

    a << {:name => 'mileage_col_int', :num_fmt => 3, :bg_color => "DCE6F1", :alignment => { :horizontal => :right } , :locked => false }
    a << {:name => 'mileage_col_int_locked', :num_fmt => 3, :bg_color => "DCE6F1", :alignment => { :horizontal => :right } , :locked => true }
    a << {:name => 'mileage_col_date', :format_code => 'MM/DD/YYYY', :bg_color => "DCE6F1", :alignment => { :horizontal => :right } , :locked => false }


    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
  end

  def include_mileage_columns?
    class_names = @asset_types.map {|id| AssetType.find(id).class_name }
    class_names.include?("Vehicle") || class_names.include?("SupportVehicle")
  end

end
