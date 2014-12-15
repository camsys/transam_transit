#------------------------------------------------------------------------------
#
# StatusUpdatesTemplateBuilder
#
# Creates a template for capturing status updates for existing inventory
#
#------------------------------------------------------------------------------
class StatusUpdatesTemplateBuilder < TemplateBuilder
  
  SHEET_NAME = StatusUpdatesFileHandler::SHEET_NAME
  
  protected
  
  # Add a row for each of the asset for the org
  def add_rows(sheet)
    @asset_types.each do |asset_type|
      assets = @organization.assets.where('asset_type_id = ?', asset_type) 
      assets.each do |a|
        asset = Asset.get_typed_asset(a)
        row_data  = []
        row_data << asset.object_key
        row_data << asset.asset_subtype.name
        row_data << asset.asset_tag
        row_data << asset.description

        row_data << nil #asset.reported_mileage
        row_data << nil #asset.reported_condition_rating.to_f
        row_data << nil #asset.reported_condition_date
        row_data << nil
        
        row_data << nil #asset.scheduled_replacement_year
        row_data << nil #asset.scheduled_rehabilitation_year
        row_data << nil

        event = nil        
        #if asset.usage_updates.empty?
          row_data << nil
          row_data << nil
          row_data << nil
        #else          
        #  event = asset.usage_updates.last
        #  row_data << event.pcnt_5311_routes
        #  row_data << event.avg_daily_use
        #  row_data << event.avg_daily_passenger_trips
        #end

        #if asset.vehicle_usage_codes.empty?
          row_data << nil
        #else
        #  codes = []
        #  asset.vehicle_usage_codes.each do |code|
        #    codes << code.name
        #  end          
        #  row_data << codes.join(',')
        #end

        #if event.nil?
          row_data << nil          
        #else
        #  row_data << event.event_date
        #end
        
        row_data << nil

        #if asset.maintenance_provider_updates.empty?
          row_data << nil
        #else
        #  row_data << asset.maintenance_provider_updates.last.maintenance_provider_type
        #end

        #if asset.storage_method_updates.empty?
          row_data << ""
        #else
        #  row_data << asset.storage_method_updates.last.vehicle_storage_method_type
        #end
        
        #if asset.operations_updates.empty?
          row_data << nil
          row_data << nil
          row_data << nil
          row_data << nil
          row_data << nil
        #else          
        #  event = asset.operations_updates.last
        #  row_data << event.avg_cost_per_mile.to_f
        #  row_data << event.avg_miles_per_gallon.to_f
        #  row_data << event.annual_maintenance_cost.to_i
        #  row_data << event.annual_insurance_cost.to_i
        #  row_data << event.event_date
        #end

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
    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    sheet.sheet_protection.password = 'transam'
    
    @subtypes = AssetSubtype.where('asset_type_id IN (?)', @asset_types)
    row = []
    @subtypes.each do |x|
      row << x.name  
    end
    sheet.add_row row
    
    @vehicle_usage_codes = VehicleUsageCode.all
    row = []
    @vehicle_usage_codes.each do |x|
      row << x.name  
    end
    sheet.add_row row

    @maintenance_provider_types = MaintenanceProviderType.all
    row = []
    @maintenance_provider_types.each do |x|
      row << x.name  
    end
    sheet.add_row row

    @vehicle_storage_method_types = VehicleStorageMethodType.all
    row = []
    @vehicle_storage_method_types.each do |x|
      row << x.name  
    end
    sheet.add_row row

  end

  # Performing post-processing 
  def post_process(sheet)
    
    # Merge Cells?
    sheet.merge_cells("A1:D1")
    sheet.merge_cells("E1:H1")
    sheet.merge_cells("I1:K1")
    sheet.merge_cells("L1:Q1")
    sheet.merge_cells("R1:Y1")
    sheet.column_widths(20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20)
    
    
    # Add data validation constraints
    
    # This is used to get the column name of a lookup table based on its length
    alphabet = ('A'..'Z').to_a
    
    # Asset Subtypes
    sheet.add_data_validation("B2:B500", { 
      :type => :list, 
      :formula1 => "lists!$A$1:$#{alphabet[@subtypes.size]}$1", 
      :allow_blank => false,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Select a value from the list', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Asset Type', 
      :prompt => 'Only values in the list are allowed'})

    
    # Mileage > 0, integer
    sheet.add_data_validation("E2:E500", { 
      :type => :whole, 
      :operator => :greaterThan, 
      :formula1 => '0', 
      :allow_blank => false,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Only values greater than 0', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Vehicle Mileage', 
      :prompt => 'Only values > 0'})

    # Condition Rating > 1 - 5, real number
    sheet.add_data_validation("F2:F500", { 
      :type => :decimal, 
      :operator => :between, 
      :formula1 => '1.0',
      :formula2 => '5.0', 
      :allow_blank => false,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Rating value must be between 1 and 5', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Condition Rating', 
      :prompt => 'Only values between 1 and 5'})

    # Scheduled replacement year, integer >= current year
    sheet.add_data_validation("I2:I500", { 
      :type => :whole, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '2014', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Replacement year cannot be before the current year.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Replacement Year', 
      :prompt => 'Enter year eg 2015'})

    # Scheduled rehabilitation year, integer >= current year
    sheet.add_data_validation("J2:J500", { 
      :type => :whole, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '2014', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Rehabilitation year cannot be before the current year.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Rehabilitation Year', 
      :prompt => 'Enter year eg 2015'})

    # Pcnt 5311 Routes, integer 0 to 100, optional
    sheet.add_data_validation("L2:L500", { 
      :type => :whole, 
      :operator => :between, 
      :formula1 => '0', 
      :formula2 => '100', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Percentage must be between 0 and 100.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Pcnt 5311 Routes', 
      :prompt => 'Enter a value between 0 and 100'})

    # Average daily use, decimal 0 to 24 hours, optional
    sheet.add_data_validation("M2:M500", { 
      :type => :decimal, 
      :operator => :between, 
      :formula1 => '0.0', 
      :formula2 => '24.0', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'value must be between 0 and 24 hours.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Average daily use', 
      :prompt => 'Enter a value between 0 and 24'})

    # Average passenger trips, integer > 0, optional
    sheet.add_data_validation("N2:N500", { 
      :type => :whole, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '0', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Value must be greater than 0.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Average passenger trips', 
      :prompt => 'Enter a value greater than or equal to 0'})

    # Usage codes, from list, optional
    sheet.add_data_validation("O2:O500", { 
      :type => :list, 
      :formula1 => "lists!$A$2:$#{alphabet[@vehicle_usage_codes.size]}$2", 
      :showDropDown => false,
      :allow_blank => false,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Select one or more values from the list.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Vehicle Usage Codes', 
      :prompt => 'Select one or more values from the list'})

    # Maintenance Provider Type, from list, optional
    sheet.add_data_validation("R2:R500", { 
      :type => :list, 
      :formula1 => "lists!$A$3:$#{alphabet[@maintenance_provider_types.size]}$3", 
      :showDropDown => false,
      :allow_blank => false,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Select a value from the list.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Maintenance Provider Type', 
      :prompt => 'Select a value from the list'})

    # Vehicle Storage Method, from list, optional
    sheet.add_data_validation("S2:S500", { 
      :type => :list, 
      :formula1 => "lists!$A$4:$#{alphabet[@vehicle_storage_method_types.size]}$4", 
      :showDropDown => false,
      :allow_blank => false,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Select a value from the list.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Storage Method Type', 
      :prompt => 'Select a value from the list'})

    # Average Cost Per Mile, decimal > 0, optional
    sheet.add_data_validation("T2:T500", { 
      :type => :decimal, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '0.0', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Value must be greater than 0.0.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Average cost per mile', 
      :prompt => 'Enter a value greater than or equal to 0.0'})

    # Average Miles per Gallon, decimal > 0, optional
    sheet.add_data_validation("U2:U500", { 
      :type => :decimal, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '0.0', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Value must be greater than 0.0.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Average miles per gallon', 
      :prompt => 'Enter a value greater than or equal to 0.0'})

    # Annual Maintenance Cost, integer > 0, optional
    sheet.add_data_validation("V2:V500", { 
      :type => :whole, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '0', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Value must be greater than 0.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Annual maintenance cost', 
      :prompt => 'Enter a value greater than or equal to 0'})

    # Annual Insurance Cost, integer > 0, optional
    sheet.add_data_validation("W2:W500", { 
      :type => :whole, 
      :operator => :greaterThanOrEqual, 
      :formula1 => '0', 
      :allow_blank => true,
      :showErrorMessage => true, 
      :errorTitle => 'Wrong input', 
      :error => 'Value must be greater than 0.', 
      :errorStyle => :information, 
      :showInputMessage => true, 
      :promptTitle => 'Annual insurance cost', 
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
        'Condition Report',
        '',
        '',
        '',
        'Replacement Report',
        '',
        '',
        'Usage Metrics Report',
        '',
        '',
        '',
        '',
        '',
        'Operational Metrics Report'
      ],
      [
        'Id', 
        'Subtype',
        'Tag',
        'Description',
        # Condition Report Columns 
        'Current Mileage', 
        'Assessed Rating', 
        'Reporting Date', 
        'Comments', 
        # Replacement Report Columns
        'Replacement Year', 
        'Rebuild Year',         
        'Comments', 
        # Usage Metrics Report Columns
        'Pcnt 5311 Routes', 
        'Avg Daily Use', 
        'Avg Passenger Trips', 
        'Usage Codes', 
        'Reporting Date',
        'Comments',
        # Operational Metrics Report Columns
        'Maintenance Provider Type',
        'Vehicle Storage Method',
        'Avg Cost Per Mile',
        'Avg MPG',
        'Annual Maintenance Cost',
        'Annual Insurance Cost',
        'Reporting Date',
        'Comments',
      ]
    ]
  end
  
  def column_styles
    [
      {:name => 'asset_id_col', :column => 0},
      {:name => 'asset_id_col', :column => 1},
      {:name => 'asset_id_col', :column => 2},
      {:name => 'asset_id_col', :column => 3},
      
      {:name => 'condition_updates_int', :column => 4},
      {:name => 'condition_updates_float', :column => 5},
      {:name => 'condition_updates_date', :column => 6},
      {:name => 'condition_updates', :column => 7},
      
      {:name => 'replacement_col_int', :column => 8},
      {:name => 'replacement_col_int', :column => 9},
      {:name => 'replacement_col', :column => 10},
      
      {:name => 'usage_updates_int', :column => 11},
      {:name => 'usage_updates_int', :column => 12},
      {:name => 'usage_updates_int', :column => 13},
      {:name => 'usage_updates', :column => 14},
      {:name => 'usage_updates_date', :column => 15},
      {:name => 'usage_updates', :column => 16},
      
      {:name => 'operations_updates', :column => 17},
      {:name => 'operations_updates', :column => 18},
      {:name => 'operations_updates_currency', :column => 19},
      {:name => 'operations_updates_float', :column => 20},
      {:name => 'operations_updates_currency', :column => 21},
      {:name => 'operations_updates_currency', :column => 22},
      {:name => 'operations_updates_date', :column => 23},
      {:name => 'operations_updates', :column => 24}
    ]
  end

  def row_types
    [
      # Asset Id Block
      :string,
      :string,
      :string,
      :string,
      # Condition Report Block
      :integer,
      :float,
      :date,
      :string,
      # Replacement/Rehab Report Block
      :integer,
      :integer,
      :string,
      # Usage Metrics Report Block
      :integer,
      :integer,
      :integer,
      :string,
      :date,
      :string,
      # Operation Metrics Report Block
      :string,
      :string,
      :float,
      :float,
      :integer,
      :integer,
      :date,
      :string      
    ]
  end
  # Merge the base class styles with BPT specific styles
  def styles
    a = []
    a << super
    # Header Styles
    a << {:name => 'asset_id_col_header',  :bg_color => "EBF1DE", :fg_color => '000000', :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'condition_updates_header', :bg_color => "F2F2F2", :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'replacement_col_header', :bg_color => "EBF1DE", :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'vehicle_characteristic_header', :bg_color => "DCE6F1", :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'usage_updates_header', :bg_color => "DDD9C4", :b => true, :alignment => { :horizontal => :center } }
    a << {:name => 'operations_updates_header', :bg_color => "F2DCDB", :b => true, :alignment => { :horizontal => :center } }
    
    
    # Row Styles
    a << {:name => 'asset_id_col',  :bg_color => "EBF1DE", :fg_color => '000000', :b => false, :alignment => { :horizontal => :left } }
    
    a << {:name => 'condition_updates', :bg_color => "F2F2F2", :alignment => { :horizontal => :left } }
    a << {:name => 'condition_updates_int', :num_fmt => 3, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } }
    a << {:name => 'condition_updates_float', :num_fmt => 2, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } }
    a << {:name => 'condition_updates_date', :num_fmt => 14, :bg_color => "F2F2F2", :alignment => { :horizontal => :right } }
    
    a << {:name => 'replacement_col', :bg_color => "EBF1DE", :b => false, :alignment => { :horizontal => :left } }
    a << {:name => 'replacement_col_int', :num_fmt => 0, :bg_color => "EBF1DE", :b => false, :alignment => { :horizontal => :right } }

    a << {:name => 'usage_updates', :bg_color => "DDD9C4", :b => false, :alignment => { :horizontal => :left } }
    a << {:name => 'usage_updates_int', :num_fmt => 1, :bg_color => "DDD9C4", :b => false, :alignment => { :horizontal => :right } }
    a << {:name => 'usage_updates_date', :num_fmt => 14, :bg_color => "DDD9C4", :b => false, :alignment => { :horizontal => :right } }

    a << {:name => 'operations_updates', :num_fmt => 0, :bg_color => "F2DCDB", :b => false, :alignment => { :horizontal => :left } }
    a << {:name => 'operations_updates_int', :num_fmt => 1, :bg_color => "F2DCDB", :b => false, :alignment => { :horizontal => :right } }
    a << {:name => 'operations_updates_float', :num_fmt => 2, :bg_color => "F2DCDB", :b => false, :alignment => { :horizontal => :right } }
    a << {:name => 'operations_updates_currency', :num_fmt => 5, :bg_color => "F2DCDB", :b => false, :alignment => { :horizontal => :right } }
    a << {:name => 'operations_updates_date', :num_fmt => 14, :bg_color => "F2DCDB", :b => false, :alignment => { :horizontal => :right } }

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