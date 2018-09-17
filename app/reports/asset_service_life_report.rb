class AssetServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', 'Pcnt', '# Past TERM Threshold', 'Pcnt']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :percent, :integer, :percent]

  COMMON_LABELS_WITH_MILEAGE = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', 'Pcnt','# Past ESL (Mi.)', 'Pcnt', '# Past TERM Threshold', 'Pcnt']
  COMMON_FORMATS_WITH_MILEAGE = [:string, :string, :integer, :integer, :percent, :integer, :percent, :integer, :percent]

  def self.get_underlying_data(organization_id_list, params)
    #asset_type_id = params[:asset_type_id].to_i > 0 ? params[:asset_type_id].to_i : 1 # default to rev vehicles
    #asset_type =  AssetType.find_by(id: asset_type_id)

    #query = TransitAsset.operational.joins(transam_asset: :organization).joins(transam_asset: {asset_subtype: :asset_type})
    #            .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
    #            .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, transam_asset_id FROM asset_events GROUP BY transam_asset_id) as rehab_events ON rehab_events.transam_asset_id = transam_assets.id')
    #            .where(transam_assets: {organization_id: organization_id_list}, policies: {active: true})

    fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
    fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

    if fta_asset_category.name  == 'Equipment'
      typed_asset_class = 'ServiceVehicle'
    else
      typed_asset_class = fta_asset_category.fta_asset_classes.first.class_name
    end

    query = typed_asset_class.constantize
                .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, transam_asset_id FROM asset_events GROUP BY transam_asset_id) as rehab_events ON rehab_events.transam_asset_id = transam_assets.id')
                .joins('LEFT JOIN manufacturer_models ON transam_assets.manufacturer_model_id = manufacturer_models.id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_milage ON recent_milage.transam_asset_id = transam_assets.id AND recent_milage.asset_event_name = "Mileage"')
                .joins('LEFT JOIN asset_events AS mileage_event ON mileage_event.id = recent_milage.asset_event_id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_rating ON recent_rating.transam_asset_id = transam_assets.id AND recent_rating.asset_event_name = "Condition"')
                .joins('LEFT JOIN asset_events AS rating_event ON rating_event.id = recent_rating.asset_event_id')
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id)
                .where(policies: {active: true})
    
    if typed_asset_class.include? 'Vehicle'
      query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id AND policy_asset_subtype_rules.fuel_type_id = service_vehicles.fuel_type_id AND policy_asset_subtype_rules.default_rule = TRUE')
    else
      query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id AND policy_asset_subtype_rules.default_rule = TRUE')
    end
    
    manufacturer_model = 'IF(manufacturer_models.name = "Other",transam_assets.other_manufacturer_model,manufacturer_models.name)'
    
    if typed_asset_class.include? 'Vehicle'
      query = query
                  .joins("LEFT JOIN fuel_types ON service_vehicles.fuel_type_id = fuel_types.id")
                  .joins("LEFT JOIN manufacturers ON transam_assets.manufacturer_id = manufacturers.id")
                  .joins("LEFT JOIN serial_numbers ON transam_assets.id = serial_numbers.identifiable_id AND serial_numbers.identifiable_type = 'TransamAsset'")
      
      if typed_asset_class == 'RevenueVehicle'
        query = query
                    .joins('INNER JOIN fta_vehicle_types ON transit_assets.fta_type_id = fta_vehicle_types.id AND transit_assets.fta_type_type="FtaVehicleType"')
        
        vehicle_type = 'fta_vehicle_types.name'
      else
        query = query
                    .joins('INNER JOIN fta_support_vehicle_types ON transit_assets.fta_type_id = fta_support_vehicle_types.id AND transit_assets.fta_type_type="FtaSupportVehicleType"')
        
        vehicle_type = 'fta_support_vehicle_types.name'
      end

      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', vehicle_type, 'transam_assets.asset_tag', 'transam_assets.external_id',  'serial_numbers.identification', 'service_vehicles.license_plate', 'transam_assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', manufacturer_model, 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")',"YEAR('#{Date.today}')*12+MONTH('#{Date.today}')-YEAR(in_service_date)*12-MONTH(in_service_date)",'IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)+ IFNULL(sum_extended_eul, 0)', 'mileage_event.current_mileage','policy_asset_subtype_rules.min_service_life_miles', 'rating_event.assessed_rating', 'policies.condition_threshold']

      labels =['Agency','Asset Type','Asset Subtype', 'FTA Vehicle Type', 'Asset Tag',  'External ID',  'VIN','License Plate',  'Manufacturer Year',  'Manufacturer', 'Model',  'Fuel Type',  'In Service Date', 'Purchase Date', 'Purchase Cost',  'Purchased New', 'Rehabbed Asset?', 'Current Age (mo.)',  'Policy ESL (mo.)', 'Current Mileage (mi.)',  'Policy ESL (mi.)', 'Current Condition (TERM)', 'Policy Condition Threshold (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :integer, :integer, :integer, :integer, :decimal, :decimal]
    elsif typed_asset_class.include? 'Facility'
      query = query
                  .joins('INNER JOIN fta_facility_types ON transit_assets.fta_type_id = fta_facility_types.id AND transit_assets.fta_type_type="FtaFacilityType"')
        
      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'fta_facility_types.name', 'transam_assets.asset_tag', 'transam_assets.external_id', 'facilities.facility_name', 'facilities.address1', 'facilities.address2', 'facilities.city', 'facilities.state','facilities.zip', 'transam_assets.manufacture_year', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")',"YEAR('#{Date.today}')*12+MONTH('#{Date.today}')-YEAR(in_service_date)*12-MONTH(in_service_date)",'IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)+ IFNULL(sum_extended_eul, 0)', 'rating_event.assessed_rating', 'policies.condition_threshold']

      labels =['Agency', 'Asset Type', 'Asset Subtype', 'FTA Facility Type', 'Asset Tag', 'External ID', 'Name', 'Address1', 'Address2', 'City', 'State', 'Zip', 'Year Built','In Service Date', 'Purchase Date', 'Purchase Cost',  'Purchased New', 'Rehabbed Asset?', 'Current Age (mo.)',  'Policy ESL (mo.)', 'Current Condition (TERM)', 'Policy Condition Threshold (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :integer, :date, :date, :currency, :string, :string, :integer, :integer, :decimal, :decimal]
    else
      query = query
                  .joins("LEFT JOIN manufacturers ON transam_assets.manufacturer_id = manufacturers.id")
                  .joins("LEFT JOIN serial_numbers ON transam_assets.id = serial_numbers.identifiable_id AND serial_numbers.identifiable_type = 'TransamAsset'")

      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id',  'transam_assets.description', 'serial_numbers.identification', 'transam_assets.quantity', 'transam_assets.quantity_unit', 'transam_assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', manufacturer_model, 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")',"YEAR('#{Date.today}')*12+MONTH('#{Date.today}')-YEAR(in_service_date)*12-MONTH(in_service_date)",'IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)+ IFNULL(sum_extended_eul, 0)', 'mileage_event.current_mileage','policy_asset_subtype_rules.min_service_life_miles', 'rating_event.assessed_rating', 'policies.condition_threshold']

      labels =[ 'Agency','Asset Type','Asset Subtype',  'Asset Tag',  'External ID', 'Name',  'Serial Number',  'Quantity','Quantity Unit','Manufacturer Year',   'Manufacturer', 'Model',  'In Service Date', 'Purchase Date', 'Purchase Cost',  'Purchased New', 'Rehabbed Asset?', 'Current Age (mo.)',  'Policy ESL (mo.)', 'Current Mileage (mi.)',  'Policy ESL (mi.)', 'Current Condition (TERM)', 'Policy Condition Threshold (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :integer, :string, :integer, :string, :string, :date, :date, :currency, :string, :string, :integer, :integer, :integer, :integer, :decimal, :decimal]

    end

    if params[:asset_subtype_id].to_i > 0
      query = query.where(assets: {asset_subtype_id: params[:asset_subtype_id]})
    end

    data = query.pluck(*cols)

    return {labels: labels, data: data, formats: formats}
  end

  def self.get_detail_data(organization_id_list, params)
    key = params[:key]
    data = []
    unless key.blank?

      hide_mileage_column = false
      fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
      fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

      if fta_asset_category.name  == 'Equipment'
        typed_asset_class = 'ServiceVehicle'
      else
        typed_asset_class = fta_asset_category.fta_asset_classes.first.class_name
      end

      query = typed_asset_class.constantize.operational
                  .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                  .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                  .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                  .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, transam_asset_id FROM asset_events GROUP BY transam_asset_id) as rehab_events ON rehab_events.transam_asset_id = transam_assets.id')
                  .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id)
                  .where(policies: {active: true}, asset_subtypes: {name: key})
                  .group('organizations.short_name', 'asset_subtypes.name')


      if typed_asset_class.include? 'Vehicle'
        query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id AND policy_asset_subtype_rules.fuel_type_id = service_vehicles.fuel_type_id')
      else
        query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')

        hide_mileage_column = true
      end

      # Generate queries for each column
      asset_counts = query.count

      if params[:months_past_esl_max].to_i > 0
        # if theres a max there must be a min
        params[:months_past_esl_min] = 1 unless params[:months_past_esl_min].to_i > 0

        query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) <= (IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_max].to_i)
      end

      if params[:months_past_esl_min].to_i > 0
        query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) >= (IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_min].to_i)
      end

      # we don't calculate age like we do in the policy as the policy is for its replacement by capital planning
      # age in this report is the months diff from today and an assets in service date
      unless params[:months_past_esl_min].to_i > 0
        past_esl_age = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) > (IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0))', Date.today, Date.today).count
      else
        past_esl_age = query.count
      end

      past_esl_condition = query
                               .joins('INNER JOIN recent_asset_events_views ON recent_asset_events_views.transam_asset_id = transam_assets.id')
                               .joins('INNER JOIN asset_events ON asset_events.id = recent_asset_events_views.asset_event_id')
                               .where('asset_events.assessed_rating < policies.condition_threshold AND asset_event_name="Condition"').count

      past_esl_miles = query
                           .joins('INNER JOIN recent_asset_events_views ON recent_asset_events_views.transam_asset_id = transam_assets.id')
                           .joins('INNER JOIN asset_events ON asset_events.id = recent_asset_events_views.asset_event_id')
                           .where('asset_events.current_mileage > policy_asset_subtype_rules.min_service_life_miles AND asset_event_name="Mileage"').count

      asset_counts.each do |k, v|
        row = [*k, v, past_esl_age[k].to_i, (past_esl_age[k].to_i*100/v.to_f+0.5).to_i] + (hide_mileage_column ? [] : [past_esl_miles[k].to_i, (past_esl_miles[k].to_i*100/v.to_f+0.5).to_i]) + [past_esl_condition[k].to_i, (past_esl_condition[k].to_i*100/v.to_f+0.5).to_i]
        data << row
      end
    end

    return {labels: hide_mileage_column ? COMMON_LABELS : COMMON_LABELS_WITH_MILEAGE, data: data, formats: hide_mileage_column ? COMMON_FORMATS : COMMON_FORMATS_WITH_MILEAGE}
  end
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_actions

    @actions = [
        {
            type: :select,
            where: :fta_asset_category_id,
            values:FtaAssetCategory.active.pluck(:name, :id),
            label: 'FTA Asset Category'
        },
        # {
        #     type: :select,
        #     where: :asset_subtype_id,
        #     values: [['All', 0]] + AssetSubtype.pluck(:name, :id),
        #     label: 'Asset Subtype'
        # },
        {
            type: :text_field,
            where: :months_past_esl_min,
            value: 1,
            label: 'Months Past ESL Min'
        },
        {
            type: :text_field,
            where: :months_past_esl_max,
            label: 'Months Past ESL Max'
        }

    ]
  end
  
  def get_data(organization_id_list, params)

    @has_key = organization_id_list.count > 1
    @clauses = Hash.new

    hide_mileage_column = false
    fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
    fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

    if fta_asset_category.name  == 'Equipment'
      typed_asset_class = 'ServiceVehicle'
    else
      typed_asset_class = fta_asset_category.fta_asset_classes.first.class_name
    end
    
    # Default scope orders by project_id
    query = typed_asset_class.constantize.operational
                .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, transam_asset_id FROM asset_events GROUP BY transam_asset_id) as rehab_events ON rehab_events.transam_asset_id = transam_assets.id')
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id)
                .where(policies: {active: true}).group('asset_subtypes.name')


    if typed_asset_class.include? 'Vehicle'
      query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id AND policy_asset_subtype_rules.fuel_type_id = service_vehicles.fuel_type_id')
    else
      query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')

      hide_mileage_column = true
    end

    # Generate queries for each column
    asset_counts = query.count

    if params[:months_past_esl_max].to_i > 0
      # if theres a max there must be a min
      params[:months_past_esl_min] = 1 unless params[:months_past_esl_min].to_i > 0

      @clauses[:months_past_esl_max] = params[:months_past_esl_max].to_i
      query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) <= (IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_max].to_i)
    end

    if params[:months_past_esl_min].to_i > 0
      @clauses[:months_past_esl_min] = params[:months_past_esl_min].to_i
      query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) >= (IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_min].to_i)
    end



    # we don't calculate age like we do in the policy as the policy is for its replacement by capital planning
    # age in this report is the months diff from today and an assets in service date

    unless params[:months_past_esl_min].to_i > 0
      past_esl_age = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) > (IF(transam_assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0))', Date.today, Date.today).count
    else
      past_esl_age = query.count
    end

    past_esl_condition = query
                             .joins('INNER JOIN recent_asset_events_views ON recent_asset_events_views.transam_asset_id = transam_assets.id')
                             .joins('INNER JOIN asset_events ON asset_events.id = recent_asset_events_views.asset_event_id')
                             .where('asset_events.assessed_rating < policies.condition_threshold AND asset_event_name="Condition"').count

    past_esl_miles = query
                             .joins('INNER JOIN recent_asset_events_views ON recent_asset_events_views.transam_asset_id = transam_assets.id')
                             .joins('INNER JOIN asset_events ON asset_events.id = recent_asset_events_views.asset_event_id')
                             .where('asset_events.current_mileage > policy_asset_subtype_rules.min_service_life_miles AND asset_event_name="Mileage"').count
    data = []

    org_label = organization_id_list.count > 1 ? 'All (Filtered) Organizations' : Organization.where(id: organization_id_list).first.short_name

    total_quantity = 0
    total_past_age = 0
    total_past_miles = 0
    total_past_condition = 0
    asset_counts.each do |k, v|
      total_quantity += v.to_i
      total_past_age += past_esl_age[k].to_i
      total_past_miles += past_esl_miles[k].to_i unless hide_mileage_column
      total_past_condition += past_esl_condition[k].to_i
      row = [org_label,*k, v, past_esl_age[k].to_i, (past_esl_age[k].to_i*100/v.to_f+0.5).to_i] + (hide_mileage_column ? [] : [past_esl_miles[k].to_i, (past_esl_miles[k].to_i*100/v.to_f+0.5).to_i]) + [past_esl_condition[k].to_i, (past_esl_condition[k].to_i*100/v.to_f+0.5).to_i]
     data << row

      #puts row.inspect
    end

    if total_quantity > 0
      data << [nil, 'Totals', total_quantity, total_past_age, (total_past_age*100/total_quantity.to_f+0.5).to_i] + (hide_mileage_column ? [] : [total_past_miles, (total_past_miles*100/total_quantity.to_f+0.5).to_i]) +[total_past_condition, (total_past_condition*100/total_quantity.to_f+0.5).to_i]
    else
      data << [nil, 'Totals', 0, total_past_age, 0] + (hide_mileage_column ? [] : [total_past_miles, 0]) +[total_past_condition, 0]
    end

    return {labels: hide_mileage_column ? COMMON_LABELS : COMMON_LABELS_WITH_MILEAGE, data: data, formats: hide_mileage_column ? COMMON_FORMATS : COMMON_FORMATS_WITH_MILEAGE}
  end

  def get_key(row)
    @has_key ? row[1] :  nil
  end

  def get_detail_path(id, key, opts={})
    ext = opts[:format] ? ".#{opts[:format]}" : ''
    @has_key ? "#{id}/details#{ext}?key=#{key}&#{@clauses.to_query}" : nil
  end

  def get_detail_view
    "generic_report_detail"
  end

end