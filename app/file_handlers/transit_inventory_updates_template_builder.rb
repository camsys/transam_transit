#-------------------------------------------------------------------------------
#
# TransitInventoryUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing transit inventory
# This adds mileage updates to the core inventory builder
#
#-------------------------------------------------------------------------------
class TransitInventoryUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    @asset_types.each do |asset_type|
      if @assets.nil?
        assets = @organization.assets.operational.where('asset_type_id = ?', asset_type).order(:asset_type_id, :asset_subtype_id, :asset_tag)
      else
        assets = @assets.operational.where('asset_type_id = ?', asset_type).order(:asset_type_id, :asset_subtype_id, :asset_tag)
      end
      assets.each do |a|
        asset = Asset.get_typed_asset(a)
        row_data  = []
        row_data << asset.object_key
        row_data << asset.asset_type.name
        row_data << asset.asset_subtype.name
        row_data << asset.asset_tag
        row_data << asset.external_id
        row_data << asset.serial_number if include_serial_number?
        row_data << asset.description

        row_data << asset.service_status_type # prev_service_status
        row_data << asset.service_status_date # prev_service_status date
        row_data << nil # current_service_status
        row_data << nil # date

        row_data << asset.reported_condition_rating # Previous Condition
        row_data << asset.reported_condition_date # Previous Condition
        row_data << nil # Current Condition
        row_data << nil # Date

        if include_mileage_columns?
          row_data << asset.reported_mileage # Previous Condition
          row_data << asset.reported_mileage_date # Previous Condition
          row_data << nil # Current mileage
          row_data << nil # Date
        end

        sheet.add_row row_data, :types => row_types
      end
    end
    # Do nothing
  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)

    # Add a lookup table worksheet and add the lookuptable values we need to it
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'

    row = []
    @service_types = ServiceStatusType.active.pluck(:name)
    @service_types.each do |x|
      row << x unless x.eql? "Unknown"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # Merge Cells?
    if include_serial_number?
      sheet.merge_cells("A1:G1")
      sheet.merge_cells("H1:K1")
      sheet.merge_cells("L1:O1")
      sheet.merge_cells("P1:S1") if include_mileage_columns?
    else
      sheet.merge_cells("A1:F1")
      sheet.merge_cells("G1:J1")
      sheet.merge_cells("K1:N1")
      sheet.merge_cells("O1:R1") if include_mileage_columns?
    end


    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Service Status
    sheet.add_data_validation(include_serial_number? ? "J3:J1000" : "I3:I1000", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@service_types.size]}$1",
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Service type',
      :prompt => 'Only values in the list are allowed'})

    # Service Status Date
    sheet.add_data_validation(include_serial_number? ? "K3:K1000" : "J3:J1000", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Status Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # Condition Rating > 1 - 5, real number
    sheet.add_data_validation(include_serial_number? ? "N2:N1000" : "M2:M1000", {
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

    # Condition date
    sheet.add_data_validation(include_serial_number? ? "O2:O1000" : "N2:N1000", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    if include_mileage_columns?
      # Milage -Integer > 0
      sheet.add_data_validation(include_serial_number? ? "R2:R1000" : "Q2:Q1000", {
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

      # Mileage date
      sheet.add_data_validation(include_serial_number? ? "S2:S1000" : "R2:R1000", {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Reporting Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})
      end
  end

  # header rows
  def header_rows
    title_row = [
      'Asset',
      '',
      '',
      '',
      '',
      ''
    ]
    title_row << ''

    title_row.concat([
      '',
      'Service Status Report',
      '',
      '',
      '',
      'Condition Report',
      '',
      '',
      ''
    ])
    if include_mileage_columns?
      title_row.concat([
        'Mileage Report',
        '',
        '',
        ''
      ])
    end

    detail_row = [
      'Id',
      'Class',
      'Subtype',
      'Tag',
      'External Id'
    ]
    if include_serial_number?
      if include_mileage_columns?
        detail_row << 'VIN'
      else
        detail_row << 'Serial Number'
      end
    end

    detail_row.concat([
      'Description',

      # Status Report Columns
      'Current Status',
      'Reporting Date',
      'New Status',
      'Reporting Date',

      # Condition Report Columns
      'Current Condition',
      'Reporting Date',
      'New Condition',
      'Reporting Date'
    ])

    if include_mileage_columns?
      detail_row.concat([
        'Current Mileage',
        'Reporting Date',
        'New Mileage',
        'Reporting Date'
      ])
    end

    [title_row, detail_row]
  end

  def column_styles
    styles = [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},
      {:name => 'asset_id_col', :column => 4},
      {:name => 'asset_id_col', :column => 5},
    ]

    if include_serial_number?
      styles << {:name => 'asset_id_col', :column => 6}
      diff = 0
    else
      diff = -1
    end

    styles.concat([
      {:name => 'service_status_string_locked', :column => 7+diff},
      {:name => 'service_status_date_locked',   :column => 8+diff},
      {:name => 'service_status_string',        :column => 9+diff},
      {:name => 'service_status_date',          :column => 10+diff},

      {:name => 'condition_float_locked', :column => 11+diff},
      {:name => 'condition_date_locked',  :column => 12+diff},
      {:name => 'condition_float',        :column => 13+diff},
      {:name => 'condition_date',         :column => 14+diff}
    ])
    if include_mileage_columns?
      styles.concat([
        {:name => 'mileage_integer_locked', :column => 15+diff},
        {:name => 'mileage_date_locked',    :column => 16+diff},
        {:name => 'mileage_integer',        :column => 17+diff},
        {:name => 'mileage_date',           :column => 18+diff}
      ])
    end
    styles
  end

  def row_types
    types = [
      # Asset Id Block
      :string,
      :string,
      :string,
      :string,
      :string,
      :string,
    ]
    types << :string if include_serial_number?

    types.concat([
      # Service Status Report Block
      :string,
      :date,
      :string,
      :date,

      # Condition Report Block
      :float,
      :date,
      :float,
      :date
    ])
    if include_mileage_columns?
      types.concat([
        # Condition Report Block
        :integer,
        :date,
        :integer,
        :date
      ])
    end
    types
  end
  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    # Header Styles
    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :left }}

    a << {:name => 'service_status_string_locked', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'service_status_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'service_status_string', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'service_status_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2DCDB", :alignment => { :horizontal => :center } , :locked => false }

    a << {:name => 'condition_float_locked', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'condition_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'condition_float', :num_fmt => 2, :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'condition_date', :format_code => 'MM/DD/YYYY', :bg_color => "DDD9C4", :alignment => { :horizontal => :center } , :locked => false }

    a << {:name => 'mileage_integer_locked', :num_fmt => 3, :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'mileage_date_locked', :format_code => 'MM/DD/YYYY', :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => true }
    a << {:name => 'mileage_integer', :num_fmt => 3, :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'mileage_date', :format_code => 'MM/DD/YYYY', :bg_color => "DCE6F1", :alignment => { :horizontal => :center } , :locked => false }

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
    class_names = @asset_types.map(&:class_name)
    if class_names.include? "Vehicle" or class_names.include? "SupportVehicle"
      true
    else
      false
    end
  end

  def include_serial_number?
    class_names = @asset_types.map(&:class_name)
    if class_names.include? "Vehicle" or class_names.include? "SupportVehicle" or class_names.include? "Equipment"
      true
    else
      false
    end
  end

end
