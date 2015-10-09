#------------------------------------------------------------------------------
#
# DispositionUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing inventory
#
#------------------------------------------------------------------------------
class DispositionUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = DispositionUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    assets = @assets.operational.where('scheduled_disposition_year IS NOT NULL').includes(:asset_type, :asset_subtype).order(:asset_type_id, :asset_subtype_id)
    assets.each do |asset|
      row_data  = []
      row_data << asset.object_key
      row_data << asset.asset_type.name
      row_data << asset.asset_subtype.name
      row_data << asset.asset_tag
      row_data << asset.external_id
      row_data << asset.description

      row_data << asset.scheduled_disposition_year
      row_data << nil
      row_data << nil
      row_data << nil
      row_data << nil
      row_data << nil

      row_data << nil
      row_data << nil
      row_data << nil
      row_data << nil
      row_data << nil
      row_data << nil

      sheet.add_row row_data, :types => row_types
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
    @disposition_types = DispositionType.active.pluck(:name)
    @disposition_types.each do |x|
      row << x unless x.eql? "Unknown"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # Merge Cells?
    sheet.merge_cells("A1:F1")
    sheet.merge_cells("G1:L1")
    sheet.merge_cells("M1:R1")

    # Add data validation constraints

    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Disposition Date
    sheet.add_data_validation("H3:H500", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Status Reporting Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})

    # Disposition Type
    sheet.add_data_validation("I3:I500", {
      :type => :list,
      :formula1 => "lists!$A$1:$#{alphabet[@disposition_types.size]}$1",
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Select a value from the list',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Disposition Type',
      :prompt => 'Only values in the list are allowed'})

    # Sales proceeds
    sheet.add_data_validation("J3:J500", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => '0',
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Value must be greater than 0.',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Sales proceeds',
      :prompt => 'Enter a value greater than or equal to 0'})

    # Age
    sheet.add_data_validation("K3:K500", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => '0',
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Value must be greater than 0.',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Sales proceeds',
      :prompt => 'Enter a value greater than or equal to 0'})

    # Mileage
    sheet.add_data_validation("L3:L500", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => '0',
      :allow_blank => false,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Value must be greater than 0.',
      :errorStyle => :information,
      :showInputMessage => true,
      :promptTitle => 'Milage',
      :prompt => 'Enter a value greater than or equal to 0'})

  end

  # header rows
  def header_rows
    [
      [
        'Asset',
        '',
        '',
        '',
        '',
        '',
        'Disposition Report',
        '',
        '',
        '',
        '',
        '',
        'Comments',
        '',
      ],
      [
        'Object Key',
        'Type',
        'Subtype',
        'Tag',
        'External Id',
        'Description',
        # Disposition Update Columns
        'Scheduled Year',
        'Disposition Date',
        'Disposition Type',
        'Sales Proceeds',
        'Age at Disposition',
        'Mileage at Disposition',
        # Comment
        'Comment'
      ]
    ]
  end

  def column_styles
    [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},
      {:name => 'asset_id_col', :column => 4},
      {:name => 'asset_id_col', :column => 5},

      {:name => 'disposition_report_integer_locked', :column => 6},
      {:name => 'disposition_report_date', :column => 7},
      {:name => 'disposition_report', :column => 8},
      {:name => 'disposition_report_currency', :column => 9},
      {:name => 'disposition_report_integer', :column => 10},
      {:name => 'disposition_report_integer', :column => 11},

      {:name => 'comment', :column => 12},

    ]
  end
  def row_types
    [
      # Asset Id Block
      :string,
      :string,
      :string,
      :string,
      :string,
      :string,
      # Disposition Report Block
      :integer,
      :string,
      :integer,
      :integer,
      :integer,
      # Comment Block
      :string
    ]
  end

  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super
    a << {:name => 'asset_id_col_header',  :bg_color => "EBF1DE", :fg_color => '000000', :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'disposition_report_header', :bg_color => "F2F2F2", :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'comment_header', :bg_color => "DCE6F1", :b => true, :alignment => { :horizontal => :center } }

    # Row Styles
    a << {:name => 'asset_id_col',  :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :left } }

    a << {:name => 'disposition_report', :bg_color => "F2F2F2", :alignment => { :horizontal => :left } }
    a << {:name => 'disposition_report_year', :num_fmt => 14, :bg_color => "F2F2F2", :alignment => { :horizontal => :left } }
    a << {:name => 'disposition_report_currency', :num_fmt => 5, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } }
    a << {:name => 'disposition_report_integer', :num_fmt => 3, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } , :locked => false }
    a << {:name => 'disposition_report_integer_locked', :num_fmt => 3, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } , :locked => true }
    a << {:name => 'disposition_report_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2F2F2", :alignment => { :horizontal => :right } , :locked => false }

    a << {:name => 'comment', :bg_color => "DCE6F1", :b => false, :alignment => { :horizontal => :left } }

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
  end

end
