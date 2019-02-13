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
        @asset_types = AssetType.where(class_name: ['Vehicle','RailCar', 'Locomotive'])
      elsif @fta_asset_class.class_name == 'ServiceVehicle'
        @asset_types = AssetType.where(name: 'Support Vehicles')
      elsif @fta_asset_class.class_name == 'CapitalEquipment'
        @asset_types = AssetType.where(class_name: 'Equipment')
      elsif (@fta_asset_class.class_name == 'Facility')
        @asset_types = AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])
      elsif (@fta_asset_class.class_name == 'Guideway')
        @asset_types = AssetType.where(class_name: 'Guideway')
      elsif (@fta_asset_class.class_name == 'Track')
        @asset_types = AssetType.where(class_name: 'Track')
      elsif (@fta_asset_class.class_name == 'PowerSignal')
        @asset_types = AssetType.where(class_name: 'PowerSignal')
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
      'fta_funding_types', 'fta_ownership_types', 'fta_vehicle_types', 'fuel_types', 'facility_capacity_types', 'vehicle_rebuild_types', 'leed_certification_types', 'fta_service_types', 'service_status_types', 'fta_support_vehicle_types', 'fta_private_mode_types'
    ]

    row_index = 1
    tables.each do |lookup|
      row = (lookup.classify.constantize.active.pluck(:name) << "")
      @lookups[lookup] = {:row => row_index, :count => row.count}
      sheet.add_row row
      row_index+=1
    end

    row = FtaModeType.active
    @lookups['fta_mode_types'] = {:row => row_index, :count => row.count + 1}
    sheet.add_row (row.map{|x| "#{x.code} - #{x.name}"} << "")
    row_index+=1


    # ADD BOOLEAN_ROW
    @lookups['booleans'] = {:row => row_index, :count => 3}
    sheet.add_row ['YES', 'NO', ""]
    row_index+=1

    row = AssetSubtype.where(asset_type_id: @asset_types.ids)
    @lookups['asset_subtypes'] = {:row => row_index, :count => row.count + 1}
    sheet.add_row (row.map{|x| "#{x.to_s} - #{x.asset_type}"} << "")
    row_index+=1

    # manufacturers
    row = (Manufacturer.where(filter: @asset_types.pluck(:class_name)).active.pluck(:name).uniq << "")
    @lookups['manufacturers'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (ManufacturerModel.active.pluck(:name) << "")
    @lookups['models'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (Chassis.active.pluck(:name) << "")
    @lookups['chassis'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # fta facility types
    row = (FtaFacilityType.where(class_name: @asset_types.pluck(:class_name)).active.pluck(:name) << "")
    @lookups['fta_facility_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # vendors
    # row = Vendor.where(organization: @organization).active.pluck(:name)
    # @lookups['vendors'] = {:row => row_index, :count => row.count}
    # sheet.add_row row
    # row_index+=1

    row = @organization ? ([@organization.name] << "") : (Organization.where(id: @organization_list).pluck(:name) << "")
    @lookups['organizations'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (Organization.all.pluck(:name) << "")
    @lookups['all_organizations'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (DualFuelType.all.map{|x| x.to_s} << "")
    @lookups['dual_fuel_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (DispositionType.active.where.not(name: 'Transferred').pluck(:name) << "")
    @lookups['disposition_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaAssetClass.active.where(id: @fta_asset_class.id).pluck(:name) << "")
    @lookups['fta_asset_classes'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaVehicleType.active.where(fta_asset_class_id: @fta_asset_class.id).pluck(:name) << "")
    @lookups['revenue_vehicle_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaSupportVehicleType.where(fta_asset_class_id: @fta_asset_class.id).active.pluck(:name) << "")
    @lookups['support_vehicle_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaEquipmentType.where(fta_asset_class_id: @fta_asset_class.id).active.pluck(:name) << "")
    @lookups['capital_equipment_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaFacilityType.active.pluck(:name) << "")
    @lookups['facility_primary_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1


    row = (FundingSource.active.pluck(:name) << "")
    @lookups['programs'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (ContractType.active.pluck(:name) << "")
    @lookups['purchase_order_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (RampManufacturer.active.pluck(:name) << "")
    @lookups['lift_ramp_manufacturers'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaFundingType.active.pluck(:name) << "")
    @lookups['fta_funding_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (EslCategory.where(class_name: @fta_asset_class.class_name).active.pluck(:name) << "")
    @lookups['esl_category'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    county_district_type = DistrictType.find_by(name: 'County')
    row = (District.where(district_type_id: county_district_type.id).active.pluck(:name) << "")
    @lookups['counties'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (LeedCertificationType.active.pluck(:name) << "")
    @lookups['leed_certification_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (FtaPrivateModeType.active.pluck(:name) << "")
    @lookups['fta_private_mode_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    facilities = (Facility.where(organization_id: @organization.id).map {|f| [f.facility_name, f.object_key, f.fta_asset_class]} << "")
    row = []
    # row = (Facility.pluck(:object_key) << "")
    facilities.each { |facility|
      unless facility == ''
        fs = facility.join(' : ')
        row << fs
      end
    }
    @lookups['facilities'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ComponentType.where(fta_asset_category_id: @fta_asset_class.fta_asset_category_id).active.pluck(:name)
    @lookups['facility_component_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (ComponentSubtype.where(parent_type: 'FtaAssetCategory').active.pluck(:name) << "")
    @lookups['facility_component_sub_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureGaugeType.active.pluck(:name)
    @lookups['infrastructure_gauge_type'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureOperationMethodType.active.pluck(:name)
    @lookups['infrastructure_operation_method_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureControlSystemType.active.pluck(:name)
    @lookups['infrastructure_control_system_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1


    if @organization
      row = InfrastructureTrack.where(organization_id: @organization.id).active.pluck(:name)
      @lookups['tracks'] = {:row => row_index, :count => row.count}
      sheet.add_row row
      row_index+=1
    end

    row = InfrastructureReferenceRail.active.pluck(:name)
    @lookups['infrastructure_reference_rails'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # :formula1 => "lists!#{get_lookup_cells('vendors')}",
    row = ["Other", ""]
    @lookups['vendors'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1
    # :formula1 => "lists!#{get_lookup_cells('vendors')}",
    #

    #units
    row = ["square foot", "square yard", "square mile", "acre", "inch", "foot", "yard", "mile",]
    @lookups['units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    #units
    row = ["feet", "inches"]
    @lookups['gauge_units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    #units
    row = ['%', 'degree', 'ft/mile']
    @lookups['track_gradient_units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    #units
    row = ['inches']
    @lookups['alignment_and_transition_units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    #units
    row = ['radius (feet)', 'degrees']
    @lookups['track_curvature_units'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['Primary Facility']
    @lookups['facility_primary_categorizations'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['Component', 'SubComponent']
    @lookups['facility_sub_component_categorizations'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['United States of America']
    @lookups['countries'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (1..20).to_a
    @lookups['1_to_20'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = (0..20).to_a
    @lookups['0_to_20'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['N/A', 'Less Than 200 Vehicles', 'Between 200 and 300 Vehicles', 'Over 300 Vehicles' ]
    @lookups['vehicle_capacity'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    # state_district_type = DistrictType.find_by(name: 'State')
    # states = (District.where(district_type: state_district_type.id).active.pluck(:name) << "")
    # if states.nil? || states.size == 0
      row = ISO3166::Country['US'].states.keys
    # else
    #   row = states
    # end
    @lookups['states'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['N', 'S']
    @lookups['latitude_directions'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['E', 'W']
    @lookups['longitutde_directions'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = ['North', 'South', 'East', 'West', 'North / South', 'East / West']
    @lookups['track_signal_directions'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = FtaGuidewayType.where(active: true).pluck(:name)
    @lookups['guideway_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    if @organization
      row = InfrastructureSubdivision.active.where(organization_id: @organization.id).pluck(:name)
    else
      row = InfrastructureSubdivision.active.pluck(:name)
    end
    @lookups['branch_subdivisions'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureBridgeType.active.pluck(:name)
    @lookups['bridge_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureBridgeType.active.pluck(:name)
    @lookups['bridge_types'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureCrossing.active.pluck(:name)
    @lookups['guideway_crossing'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    row = InfrastructureSegmentType.active.pluck(:name)
    @lookups['segment_type'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

    if @organization
      row = InfrastructureDivision.active.where(organization_id: @organization.id).pluck(:name)
    else
      row = InfrastructureDivision.active.pluck(:name)
    end

    @lookups['mainline'] = {:row => row_index, :count => row.count}
    sheet.add_row row
    row_index+=1

  end

  def add_columns(sheet)
    @builder_detailed_class.add_columns(sheet, self, @organization, @fta_asset_class, EARLIEST_DATE)
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
      sheet.add_row Array.new(sheet.column_info.count){nil}
    end
  end

  def post_process(sheet)
    #@builder_detailed_class.post_process(sheet)

    # protect sheet so you cannot update cells that are locked
    sheet.sheet_protection

    # row style on category row
    category_row_style = sheet.workbook.styles.add_style({:bg_color => '6BB14A', :alignment => { :horizontal => :left, :wrap_text => true }, :locked => true })
    sheet.row_style 0, category_row_style
  end

  def create_list_of_fields(workbook)
    required_fields = []
    optional_fields = []
    other_fields = []

    @column_styles.each do |key, value|
      style_name = @style_cache.key(value)
      if style_name.include?('required')
        required_fields << key
      elsif style_name.include?('recommended')
        optional_fields << key
      elsif style_name.include?('other')
        other_fields << key
      end
    end

    all_fields = {required: {fields: required_fields, string: 'Required'},
           recommended: {fields: optional_fields, string: 'Optional'},
           other: {fields: other_fields, string: 'If Other or Applicable (only required if primary field is required)'}}

    list_of_fields_sheet = workbook.add_worksheet :name => 'List of Fields'
    list_of_fields_sheet.sheet_protection.password = 'transam'

    list_of_fields_sheet.add_row ['Attributes', 'Importance'], :style => workbook.styles.add_style({:sz => 18, :fg_color => 'ffffff', :bg_color => '5e9cd3'})

    start = 2
    merged_cell_style = workbook.styles.add_style({:format_code => '@', :bg_color => 'FFFFFF', :alignment => { :horizontal => :center, :vertical => :center, :wrap_text => true }, :border => { :style => :thin, :color => "C0C0C0" }, :locked => true })

    all_fields.each do |category, contents|
      unless contents[:fields].empty?
        contents[:fields].each_with_index  do |field, index|
          list_of_fields_sheet.add_row (index == 0 ? [field, contents[:string]] : [field, ""]), :style => [@style_cache["#{category}_header_string"], merged_cell_style]
        end

        end_of_category = start + contents[:fields].count - 1
        list_of_fields_sheet.merge_cells("B#{start}:B#{end_of_category}")

        start += contents[:fields].count
      end
    end
  end

  def create_pick_lists(workbook)
    pick_lists_sheet = workbook.add_worksheet :name => 'Pick Lists'
    pick_lists_sheet.sheet_protection.password = 'transam'
    @pick_list_cache.delete(:index)
    longest = @pick_list_cache.delete(:longest)

    pick_lists_sheet.add_row @pick_list_cache.keys, :style => @style_cache["other_header_string"]
    @pick_list_cache.each do |category, data|
      data.fill("", data.count..longest)
    end
    @pick_list_cache.values.transpose.each do |row|
      pick_lists_sheet.add_row row, :style => @style_cache["recommended_string"]
    end
  end

  def index_pick_list(row_index, count)
    @pick_list_cache[:index] = row_index
    @pick_list_cache[:longest] ||= count
    if count > @pick_list_cache[:longest]
      @pick_list_cache[:longest] = count
    end
  end

  def styles

    a = []

    light_green_fill = 'CCFFCC'
    grey_fill = 'DBDBDB'
    white_fill = 'FFFFFF'

    colors = {required_header: light_green_fill, required: white_fill, recommended_header: white_fill, recommended: white_fill, other_header: grey_fill, other: grey_fill}


    colors.each do |key, color|
      a << {:name => "#{key}_string", :format_code => '@', :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true }, :locked => (key.to_s.include?('header') ? true : false) }
      a << {:name => "#{key}_currency", :num_fmt => 5, :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true }, :locked => (key.to_s.include?('header') ? true : false) }
      a << {:name => "#{key}_date", :format_code => 'MM/DD/YYYY', :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true }, :locked => (key.to_s.include?('header') ? true : false) }
      a << {:name => "#{key}_float", :num_fmt => 2, :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true } , :locked => (key.to_s.include?('header') ? true : false) }
      a << {:name => "#{key}_integer", :num_fmt => 3, :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true } , :locked => (key.to_s.include?('header') ? true : false) }
      a << {:name => "#{key}_year", :num_fmt => 1, :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true } , :locked => (key.to_s.include?('header') ? true : false) }
      a << {:name => "#{key}_pcnt", :format_code => '0&quot;%&quot;', :bg_color => color, :alignment => { :horizontal => :left, :wrap_text => true } , :locked => (key.to_s.include?('header') ? true : false) }
    end

    # Needed in case additional worksheet-specific styles need to be added.
    # if @builder_detailed_class.respond_to?('styles')
    #   a << @builder_detailed_class.styles
    # end

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
    elsif @asset_class_name == 'Facility'
      @builder_detailed_class = TransitFacilityTemplateDefiner.new
    elsif @asset_class_name == 'FacilityComponent'
      @builder_detailed_class = TransitFacilitySubComponentTemplateDefiner.new
    elsif @asset_class_name == 'Guideway'
      @builder_detailed_class = TransitInfrastructureGuidewayTemplateDefiner.new
    elsif @asset_class_name == 'Track'
      @builder_detailed_class = TransitInfrastructureTrackTemplateDefiner.new
    elsif @asset_class_name == 'PowerSignal'
      @builder_detailed_class = TransitInfrastructurePowerSignalTemplateDefiner.new
    end
  end

end
