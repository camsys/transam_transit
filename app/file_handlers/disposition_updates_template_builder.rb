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
    @asset_types.each do |asset_type|
      assets = @organization.assets.where('asset_type_id = ? AND scheduled_disposition_year IS NOT NULL', asset_type) 
      assets.each do |a|
        asset = Asset.get_typed_asset(a)
        row_data  = []
        row_data << asset.object_key
        row_data << asset.asset_subtype.name
        row_data << asset.asset_tag
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
                
        sheet.add_row row_data, :types => row_types
      end
    end
    # Do nothing
  end

  # Configure any other implementation specific options for the workbook
  # such as lookup table worksheets etc.
  def setup_workbook(workbook)
        
    # Add a lookup table worksheet and add the lookuptable values we need to it
    sheet = workbook.add_worksheet :name => 'lists', :state => :hidden
    sheet.sheet_protection.password = 'transam'
        
    @disposition_types = DispositionType.all
    row = []
    @disposition_types.each do |x|
      row << x.name  
    end
    sheet.add_row row

  end

  # Performing post-processing 
  def post_process(sheet)
    # Merge Cells?
    sheet.merge_cells("A1:D1")
    sheet.merge_cells("E1:G1")
    sheet.merge_cells("H1:L1")
    sheet.column_widths(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
    
    # Add data validation constraints
    
    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    
    # Asset Subtypes
    sheet.add_data_validation("F3:F500", { 
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
    sheet.add_data_validation("G3:G500", { 
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
    
  end

  # header rows
  def header_rows
    [
      [
        'Asset',
        '',
        '',
        '',
        'Disposition Report',
        '',
        '',
        'New Owner'
      ],
      [
        'Id', 
        'Subtype',
        'Tag',
        'Description',
        # Disposition Update Columns 
        'Disposition Year', 
        'Disposition Type', 
        'Sales Proceeds', 
        # New Owner
        'Name', 
        'Address', 
        'City', 
        'State', 
        'Zip',
        'Comments'
      ]
    ]
  end
  
  def column_styles
    [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},

      {:name => 'disposition_report_year', :column => 4},
      {:name => 'disposition_report', :column => 5},
      {:name => 'disposition_report_currency', :column => 6},
      
      
      {:name => 'new_owner', :column => 7},
      {:name => 'new_owner', :column => 8},
      {:name => 'new_owner', :column => 9},
      {:name => 'new_owner', :column => 10},
      {:name => 'new_owner', :column => 11},
      {:name => 'new_owner', :column => 12}
    ]
  end
  def row_types
    [
      # Asset Id Block
      :string,
      :string,
      :string,
      :string,
      # Disposition Report Block
      :integer,
      :string,
      :integer,
      # New Owner Block
      :string,
      :string,
      :string,
      :string,
      :string,
      :string
    ]
  end

  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super
    a << {:name => 'asset_id_col_header',  :bg_color => "EBF1DE", :fg_color => '000000', :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'disposition_report_header', :bg_color => "F2F2F2", :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'new_owner_header', :bg_color => "DCE6F1", :b => true, :alignment => { :horizontal => :center } }

    # Row Styles
    a << {:name => 'asset_id_col',  :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :left } }

    a << {:name => 'disposition_report', :bg_color => "F2F2F2", :alignment => { :horizontal => :left } }
    a << {:name => 'disposition_report_year', :num_fmt => 14, :bg_color => "F2F2F2", :alignment => { :horizontal => :left } }
    a << {:name => 'disposition_report_currency', :num_fmt => 5, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } }

    a << {:name => 'new_owner', :bg_color => "DCE6F1", :b => false, :alignment => { :horizontal => :left } }
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