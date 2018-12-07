#------------------------------------------------------------------------------
#
# DispositionUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing inventory
#
#------------------------------------------------------------------------------
class TransitDispositionUpdatesTemplateBuilder < TemplateBuilder

  SHEET_NAME = DispositionUpdatesFileHandler::SHEET_NAME

  protected

  # Add a row for each of the asset for the org
  def add_rows(sheet)
    if @assets.nil?
      assets =  @asset_class_name.constantize.operational.where(organization_id: @organization.id).where(Rails.application.config.asset_seed_class_name.foreign_key => @search_parameter.id)
    else
      assets = @assets
    end

    assets.each do |asset|
      next unless asset.disposable?

      row_data = []
      row_data << asset.object_key
      row_data << asset.organization.short_name
      row_data << asset.asset_tag
      row_data << asset.external_id
      row_data << asset.fta_asset_class.name
      row_data << asset.fta_type.name
      row_data << asset.asset_subtype
      row_data << asset.try(:esl_category).try(:name)
      row_data << asset.description
      if @fta_asset_class.class_name == 'Facility'
        row_data << asset.parent.try(:facility_name) || asset.facility_name
      else
        row_data << asset.try(:serial_number)
      end


      # Disposition report
      row_data << nil
      row_data << nil
      row_data << nil

      if include_mileage_columns?
        row_data << nil
      end

      sheet.add_row row_data
    end
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
      row << x unless x.eql? "Unknown" or x.eql? "Transferred"
    end
    sheet.add_row row

  end

  # Performing post-processing
  def post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # Merge Cells
    sheet.merge_cells("A1:J1")

    if include_mileage_columns?
      sheet.merge_cells("K1:N1")
    else
      sheet.merge_cells("K1:M1")
    end


    # Add data validation constraints

    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    earliest_date = SystemConfig.instance.epoch

    # Disposition Type
    sheet.add_data_validation("K3:K1000", {
        :type => :list,
        :formula1 => "lists!$A$1:$#{alphabet[@disposition_types.size]}$1",
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Disposition Type',
        :prompt => 'Only values in the list are allowed'})

    # Disposition Date
    sheet.add_data_validation("L3:L1000", {
      :type => :time,
      :operator => :greaterThan,
      :formula1 => earliest_date.strftime("%-m/%d/%Y"),
      :allow_blank => true,
      :errorTitle => 'Wrong input',
      :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Disposition Date',
      :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"})


    # Sales proceeds
    sheet.add_data_validation("M3:M1000", {
      :type => :whole,
      :operator => :greaterThanOrEqual,
      :formula1 => '0',
      :allow_blank => true,
      :showErrorMessage => true,
      :errorTitle => 'Wrong input',
      :error => 'Value must be greater than 0.',
      :errorStyle => :stop,
      :showInputMessage => true,
      :promptTitle => 'Sales proceeds',
      :prompt => 'Enter a value greater than or equal to 0'})

    if include_mileage_columns?
      # Mileage
      sheet.add_data_validation("N3:N1000", {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :allow_blank => true,
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Value must be greater than 0.',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Mileage at disposition',
        :prompt => 'Enter a value greater than or equal to 0'})
    end

  end

  # header rows
  def header_rows

    title_row = [
        'Asset','','','','','','','',
    ]

    title_row << ''

    title_row.concat([
      'Disposition Report',
      '',
      ''
    ])

    if include_mileage_columns?
      title_row.concat([''])
    end

    detail_row = [
        'Object Key',
        'Agency',
        'Asset ID',
        'External ID',
        'Class',
        'Type',
        'Subtype',
        'ESL Category',
        'Description'
    ]
    if include_mileage_columns?
      detail_row << 'VIN'
    elsif @fta_asset_class.class_name == 'Facility'
      detail_row << 'Facility Name'
    else
      detail_row << 'Serial Number'
    end

    detail_row.concat([
      # Disposition Update Columns
      'Disposition Type',
      'Disposition Date',
      'Sales Proceeds'
    ])

    if include_mileage_columns?
      detail_row.concat(['Mileage At Disposition'])
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
      {:name => 'asset_id_col', :column => 6},
      {:name => 'asset_id_col', :column => 7},
      {:name => 'asset_id_col', :column => 8},
      {:name => 'asset_id_col', :column => 9}
    ]

    styles.concat([
      {:name => 'disposition_report', :column => 10},
      {:name => 'disposition_report_date', :column => 11},
      {:name => 'disposition_report_currency', :column => 12}
    ])

    if include_mileage_columns?
      styles.concat([{:name => 'disposition_report_integer', :column => 13}])
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
    types << :string

    types.concat([
      # Disposition Report Block
      :string,
      :integer,
      :integer
    ])

    if include_mileage_columns?
      types.concat([:integer])
    end
    types
  end

  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super

    a << {:name => 'asset_id_col', :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :center }, :locked => true}

    a << {:name => 'disposition_report', :bg_color => "F2F2F2", :alignment => { :horizontal => :center }, :locked => false }
    a << {:name => 'disposition_report_currency', :num_fmt => 5, :bg_color => "F2F2F2", :alignment => { :horizontal => :center }, :locked => false }
    a << {:name => 'disposition_report_integer', :num_fmt => 3, :bg_color => "F2F2F2", :alignment => { :horizontal => :center } , :locked => false }
    a << {:name => 'disposition_report_date', :format_code => 'MM/DD/YYYY', :bg_color => "F2F2F2", :alignment => { :horizontal => :center } , :locked => false }

    a.flatten
  end

  def worksheet_name
    'Updates'
  end

  private

  def initialize(*args)
    super
    @fta_asset_class = FtaAssetClass.find_by(id: @asset_seed_class_id)
  end

  def include_mileage_columns?
    if @fta_asset_class.class_name.include? "Vehicle"
      true
    else
      false
    end
  end
end
