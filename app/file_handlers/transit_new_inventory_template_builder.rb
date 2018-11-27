class TransitNewInventoryTemplateBuilder < UpdatedTemplateBuilder

  SHEET_NAME = TransitNewInventoryFileHandler::SHEET_NAME

  protected

  def setup_workbook(workbook)
    super

    @default_values = {}

    styles.each do |s|
      @style_cache[s[:name]] = workbook.styles.add_style(s)
    end

    # add instructions
    instructions = @builder_detailed_class.setup_instructions

    instructions_sheet = workbook.add_worksheet :name => 'Instructions'
    instructions_sheet.sheet_protection.password = 'transam'

    instructions_sheet.add_row ['Instructions'], :style => workbook.styles.add_style({:sz => 18, :fg_color => 'ffffff', :bg_color => '5e9cd3'})
    instructions_sheet.add_row [nil] # blank line
    instruction_style = workbook.styles.add_style({:bg_color => 'BED7ED', :alignment => {:wrap_text => true}})
    instructions.each do |i|
      instructions_sheet.add_row [i], :style => instruction_style
      instructions_sheet.add_row [nil], :style => instruction_style # blank line
    end

    instructions_sheet.column_widths *[100]
  end

  def setup_lookup_sheet(workbook)
    super

    if @asset_types.nil? || @fta_asset_class.nil?
      @fta_asset_class = FtaAssetClass.find_by(id: @asset_seed_class_id)
      if @fta_asset_class.class_name == 'RevenueVehicle'
        @asset_types = AssetType.where(name: 'Revenue Vehicles')
      end
      if @fta_asset_class.class_name == 'ServiceVehicle'
        @asset_types = AssetType.where(name: 'Support Vehicle')
      end
      if @fta_asset_class.class_name == 'CapitalEquipment'
        @asset_types = AssetType.where(class_name: 'Equipment')
      end


    end

    # ------------------------------------------------
    #
    # Tab for lookup tables
    #
    # ------------------------------------------------

    sheet = workbook.add_worksheet :name => 'lists', :state => :very_hidden
    # sheet.sheet_protection.password = 'transam'


    tables = [
      'fta_funding_types', 'fta_ownership_types', 'fta_vehicle_types', 'fuel_types', 'facility_capacity_types', 'vehicle_rebuild_types', 'leed_certification_types', 'fta_service_types', 'service_status_types', 'fta_mode_types', 'fta_support_vehicle_types', 'fta_private_mode_types'
    ]

    row_index = 1
    tables.each do |lookup|
      row = lookup.classify.constantize.active.pluck(:name)
      @lookups[lookup] = {:row => row_index, :count => row.count}
      sheet.add_row row
      row_index+=1
    end

    # ADD BOOLEAN_ROW
    @lookups['booleans'] = {:row => row_index, :count => 2}
    sheet.add_row ['YES', 'NO']
    row_index+=1

    row = AssetSubtype.where(asset_type_id: @asset_types.ids)
    @lookups['asset_subtypes'] = {:row => row_index, :count => row.count}
    sheet.add_row row.map{|x| "#{x.to_s} - #{x.asset_type}"}
    row_index+=1

    # manufacturers
    row = Manufacturer.where(filter: @asset_types.pluck(:class_name)).active.pluck(:name)
    @lookups['manufacturers'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ManufacturerModel.active.pluck(:name)
    @lookups['models'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = Chassis.active.pluck(:name)
    @lookups['chassis'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # fta facility types
    row = FtaFacilityType.where(class_name: @asset_types.pluck(:class_name)).active.pluck(:name)
    @lookups['fta_facility_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # vendors
    # row = Vendor.where(organization: @organization).active.pluck(:name)
    # @lookups['vendors'] = {:row => row_index, :count => row.count}
    # sheet.add_row row
    # row_index+=1

    #units
    row = Uom.units
    @lookups['units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1


    row = Organization.where(id: @organization_list).pluck(:name)
    @lookups['organizations'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = DualFuelType.all.map{|x| x.to_s}
    @lookups['dual_fuel_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = DispositionType.active.where.not(name: 'Transferred').pluck(:name)
    @lookups['disposition_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = FtaAssetClass.active.where(id: @fta_asset_class.id).pluck(:name)
    @lookups['fta_asset_classes'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = FtaVehicleType.active.where(fta_asset_class_id: @fta_asset_class.id).pluck(:name)
    @lookups['revenue_vehicle_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = FtaVehicleType.active.where(fta_asset_class_id: @fta_asset_class.id).pluck(:name)
    @lookups['revenue_vehicle_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = FundingSource.active.pluck(:name)
    @lookups['programs'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ContractType.active.pluck(:name)
    @lookups['purchase_order_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = RampManufacturer.active.pluck(:name)
    @lookups['lift_ramp_manufacturers'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # :formula1 => "lists!#{get_lookup_cells('esl_category')}",
    # :formula1 => "lists!#{get_lookup_cells('vendors')}",
    # :formula1 => "lists!#{get_lookup_cells('funding_type')}",

    row = ["Heavy-Duty Large Bus", "Heavy-Duty Small Bus", "Medium-Duty and Purpose-Built Bus", "Light Duty Mid-Sized Bus", 'Light Duty Small Bus, Cutaways, and Modified Van',
        "Electric Trolley-Bus", "Steel-Wheel Trolley", "Ferry", "Rail Vehicle"]
    @lookups['esl_category'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ["Other"]
    @lookups['vendors'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ["Urbanized Area Formula Program (UA)", "Other Federal Funds (OF)", "Non-Federal Public Funds (NFPA)", "Non-Federal Private Funds (NFPE)", "Rural Area Formula Program (RAFP)",
           "Enhanced Mobility of Seniors & Individuals with Disabilities (EMSID)"]
    @lookups['funding_type'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # :formula1 => "lists!#{get_lookup_cells('esl_category')}",
    # :formula1 => "lists!#{get_lookup_cells('vendors')}",
    # :formula1 => "lists!#{get_lookup_cells('funding_type')}",
  end

  def add_columns(sheet)
    @builder_detailed_class.add_columns(sheet, self, @organizaiton, @fta_asset_class, EARLIEST_DATE)
  end

  def add_rows(sheet)
    # default_row = []
    # @header_category_row.each do |key, fields|
    #   fields.each do |i|
    #     default_row << (@default_values[i].present? ? @default_values[i][0] : 'SET DEFAULT')
    #   end
    # end
    # sheet.add_row default_row

    1000.times do
      sheet.add_row Array.new(49){nil}
    end
  end

  def post_process(sheet)
    # @builder_detailed_class.post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    # sheet.sheet_protection

    # override default row style
    default_row_style = sheet.workbook.styles.add_style({:bg_color => 'EEA2AD', :locked => false})
    sheet.rows[2].style = default_row_style

    cell_count = 0
    puts @default_values.to_s
    @header_category_row.each do |key, fields|
      fields.each do |i|
        if @default_values[i].present? && @default_values[i][1].present?
          style_type = @default_values[i][1].to_s
          sheet.rows[2].cells[cell_count].style = @style_cache[style_type]
        end
        cell_count += 1
      end
    end


  end

  def styles

    a = []

    dark_green_fill = '6BB14A'
    light_green_fill = '6BB14A'
    grey_fill = 'DBDBDB'
    white_fill = 'FFFFFF'

    colors = {required: light_green_fill, recommended: white_fill, other: grey_fill}


    colors.each do |key, color|
      a << {:name => "#{key}_string", :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true }, :locked => false }
      a << {:name => "#{key}_currency", :num_fmt => 5, :bg_color => color, :alignment => { :horizontal => :left }, :locked => false }
      a << {:name => "#{key}_date", :format_code => 'MM/DD/YYYY', :bg_color => color, :alignment => { :horizontal => :left }, :locked => false }
      a << {:name => "#{key}_float", :num_fmt => 2, :bg_color => color, :alignment => { :horizontal => :left } , :locked => false }
      a << {:name => "#{key}_integer", :num_fmt => 3, :bg_color => color, :alignment => { :horizontal => :left } , :locked => false }
      a << {:name => "#{key}_pcnt", :num_fmt => 9, :bg_color => color, :alignment => { :horizontal => :left } , :locked => false }
    end

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
    unless @builder_detailed_class.nil?
      @builder_detailed_class.worksheet_name
    else
      'Updates'
    end

  end

  private

  def initialize(*args)
    super

    if @asset_class_name == 'RevenueVehicle'
      @builder_detailed_class = TransitRevenueVehicleTemplateDefiner.new
    elsif @asset_class_name == 'ServiceVehicle'
      @builder_detailed_class = TransitServiceVehicleTemplateDefiner.new
    elsif @asset_class_name == 'CapitalEquipment'
      @builder_detailed_class = TransitCapitalEquipmentTemplateDefiner.new
    end
  end

end
