class AssetTamPolicyServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Asset Classification', 'Quantity','# Past ULB/TERM', 'Pcnt', 'Avg Age', 'Avg TERM Condition']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :percent, :integer, :decimal]

  def self.get_underlying_data(organization_id_list, params)

    asset_type_id = params[:asset_type_id].to_i > 0 ? params[:asset_type_id].to_i : 1 # default to rev vehicles
    asset_type =  AssetType.find_by(id: asset_type_id)

    query = asset_type.class_name.constantize.operational.joins(:organization, :asset_subtype)
                .includes(:asset_type)
                .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                .where(assets: {organization_id: organization_id_list}, policies: {active: true})

    if asset_type.class_name.include? 'Vehicle'
      query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id AND policy_asset_subtype_rules.fuel_type_id = assets.fuel_type_id')
    else
      query = query.joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')
    end

    if asset_type.class_name.include? 'Vehicle'
      query = query.includes(:fuel_type, :manufacturer, :fta_vehicle_type)
      if asset_type.class_name == 'Vehicle'
        vehicle_type = 'fta_vehicle_types.name'
      else
        vehicle_type = "''"
      end

      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', vehicle_type, 'assets.asset_tag', 'assets.external_id',	'assets.serial_number', 'assets.license_plate', 'assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', 'assets.manufacturer_model', 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'assets.in_service_date', 'assets.purchase_date', 'assets.purchase_cost', 'IF(assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")',"YEAR('#{Date.today}')*12+MONTH('#{Date.today}')-YEAR(in_service_date)*12-MONTH(in_service_date)",'IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)+ IFNULL(sum_extended_eul, 0)', 'assets.reported_mileage','policy_asset_subtype_rules.min_service_life_miles', 'assets.reported_condition_rating', 'policies.condition_threshold']

      labels =[ 'Agency','Asset Type','Asset Subtype',	'FTA Vehicle Type',	'Asset Tag',	'External ID',	'VIN','License Plate',	'Manufacturer Year', 	'Manufacturer',	'Model',	'Fuel Type',	'In Service Date', 'Purchase Date',	'Purchase Cost',	'Purchased New', 'Rehabbed Asset?',	'Current Age (mo.)', 	'Policy ESL (mo.)',	'Current Mileage (mi.)',	'Policy ESL (mi.)',	'Current Condition (TERM)',	'Policy Condition Threshold (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :integer, :integer, :integer, :integer, :decimal, :decimal]
    elsif asset_type.class_name.include? 'Facility'
      query = query.includes(:fta_facility_type)

      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'fta_facility_types.name', 'assets.asset_tag', 'assets.external_id',	'assets.description', 'assets.address1', 'assets.address2', 'assets.city', 'assets.state','assets.zip', 'assets.manufacture_year', 'assets.in_service_date', 'assets.purchase_date', 'assets.purchase_cost', 'IF(assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")',"YEAR('#{Date.today}')*12+MONTH('#{Date.today}')-YEAR(in_service_date)*12-MONTH(in_service_date)",'IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)+ IFNULL(sum_extended_eul, 0)', 'assets.reported_condition_rating', 'policies.condition_threshold']

      labels =['Agency','Asset Type','Asset Subtype',	'FTA Facility Type',	'Asset Tag',	'External ID',	'Name','Address1',	'Address2', 	'City',	'State',	'Zip',	'Year Built','In Service Date', 'Purchase Date',	'Purchase Cost',	'Purchased New', 'Rehabbed Asset?',	'Current Age (mo.)', 	'Policy ESL (mo.)',	'Current Condition (TERM)',	'Policy Condition Threshold (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :integer, :date, :date, :currency, :string, :string, :integer, :integer, :integer, :integer, :decimal, :decimal]
    else
      query = query.includes(:manufacturer)

      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'assets.asset_tag', 'assets.external_id',	'assets.description','assets.serial_number', 'assets.quantity', 'assets.quantity_units', 'assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', 'assets.manufacturer_model', 'assets.in_service_date', 'assets.purchase_date', 'assets.purchase_cost', 'IF(assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")',"YEAR('#{Date.today}')*12+MONTH('#{Date.today}')-YEAR(in_service_date)*12-MONTH(in_service_date)",'IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)+ IFNULL(sum_extended_eul, 0)', 'assets.reported_mileage','policy_asset_subtype_rules.min_service_life_miles', 'assets.reported_condition_rating', 'policies.condition_threshold']

      labels =[ 'Agency','Asset Type','Asset Subtype',	'Asset Tag',	'External ID', 'Name',	'Serial Number',	'Quantity','Quantity Unit','Manufacturer Year', 	'Manufacturer',	'Model',	'In Service Date', 'Purchase Date',	'Purchase Cost',	'Purchased New', 'Rehabbed Asset?',	'Current Age (mo.)', 	'Policy ESL (mo.)',	'Current Mileage (mi.)',	'Policy ESL (mi.)',	'Current Condition (TERM)',	'Policy Condition Threshold (TERM)']

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

      # Default scope orders by project_id
      query = Asset.operational.joins(:organization, :asset_subtype)
                  .joins('LEFT JOIN fta_vehicle_types ON assets.fta_vehicle_type_id = fta_vehicle_types.id')
                  .joins('LEFT JOIN fta_support_vehicle_types ON assets.fta_support_vehicle_type_id = fta_support_vehicle_types.id')
                  .joins('LEFT JOIN fta_facility_types ON assets.fta_facility_type_id = fta_facility_types.id')
                  .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                  .where(assets: {organization_id: organization_id_list})
                  .group('organizations.short_name')



      hide_mileage_column = false
      asset_type_id = params[:asset_type_id].to_i > 0 ? params[:asset_type_id].to_i : 1 # rev vehicles if none selected

      query = query.where(assets: {asset_type_id: asset_type_id})

      if params[:asset_subtype_id].to_i > 0
        query = query.where(assets: {asset_subtype_id: params[:asset_subtype_id]})
      end

      fta_asset_category = FtaAssetCategory.asset_types(AssetType.where(id: asset_type_id)).first
      asset_levels = fta_asset_category.asset_levels
      asset_level_class = asset_levels.table_name

      detail_search = Hash.new
      detail_search[asset_level_class] = {id: FtaVehicleType.find_by(name: key).id}
      query = query.where(detail_search)

      query =

          if TamPolicy.first
            policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: 'activated'}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

            query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = #{asset_level_class.singularize}_id").group("#{asset_level_class}.name")
          end

      hide_mileage_column = (AssetType.find_by(id: asset_type_id).class_name.include? 'Facility')

      # Generate queries for each column
      asset_counts = query.distinct.count('assets.id')

      unless params[:months_past_esl_min].to_i > 0
        params[:months_past_esl_min] = 1
      end
      past_ulb_counts = query.distinct.where('12*(ulbs.useful_life_benchmark + IFNULL(sum_extended_eul, 0)/12 - (YEAR(CURDATE()) - assets.manufacture_year)) >= ?', params[:months_past_esl_min].to_i)
      if params[:months_past_esl_max].to_i > 0
        past_ulb_counts = past_ulb_counts.distinct.where('12*(ulbs.useful_life_benchmark + IFNULL(sum_extended_eul, 0)/12 - (YEAR(CURDATE()) - assets.manufacture_year)) <= ?', params[:months_past_esl_max].to_i)
      end
      past_ulb_counts = past_ulb_counts.count('assets.id')

      total_age = query.sum('YEAR(CURDATE()) - assets.manufacture_year')
      total_mileage = query.sum(:reported_mileage)
      total_condition = query.sum(:reported_condition_rating)

      asset_counts.each do |k, v|
        row = [*k, v, past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f + 0.5).to_i, (total_condition[k].to_i/v.to_f + 0.5).to_i ]
        unless hide_mileage_column
          row << (total_mileage[k].to_i/v.to_f + 0.5).to_i
        end
        data << row
      end


    end

    return {labels: COMMON_LABELS + (hide_mileage_column ? [] : ['Avg Mileage']), data: data, formats: COMMON_FORMATS + (hide_mileage_column ? [] : [:integer])}

  end

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)
    @clauses = Hash.new
    @clauses[:rule_set_id] = RuleSet.find_by(class_name: 'TamPolicy').id

    # Default scope orders by project_id
    query = Asset.operational.joins(:organization, :asset_subtype)
                .joins('LEFT JOIN fta_vehicle_types ON assets.fta_vehicle_type_id = fta_vehicle_types.id')
                .joins('LEFT JOIN fta_support_vehicle_types ON assets.fta_support_vehicle_type_id = fta_support_vehicle_types.id')
                .joins('LEFT JOIN fta_facility_types ON assets.fta_facility_type_id = fta_facility_types.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                .where(assets: {organization_id: organization_id_list})

    hide_mileage_column = false
    asset_type_id = params[:asset_type_id].to_i > 0 ? params[:asset_type_id].to_i : 1 # rev vehicles if none selected

    query = query.where(assets: {asset_type_id: asset_type_id})

    if params[:asset_subtype_id].to_i > 0
      query = query.where(assets: {asset_subtype_id: params[:asset_subtype_id]})
    end

    fta_asset_category = FtaAssetCategory.asset_types(AssetType.where(id: asset_type_id)).first
    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    query =

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: 'activated'}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

      query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = #{asset_level_class.singularize}_id").group("#{asset_level_class}.name")
    end

    hide_mileage_column = (AssetType.find_by(id: asset_type_id).class_name.include? 'Facility')

    # Generate queries for each column
    asset_counts = query.distinct.count('assets.id')

    unless params[:months_past_esl_min].to_i > 0
        params[:months_past_esl_min] = 1
    end
    past_ulb_counts = query.distinct.where('12*(ulbs.useful_life_benchmark + IFNULL(sum_extended_eul, 0)/12 - (YEAR(CURDATE()) - assets.manufacture_year)) >= ?', params[:months_past_esl_min].to_i)
    if params[:months_past_esl_max].to_i > 0
      past_ulb_counts = past_ulb_counts.distinct.where('12*(ulbs.useful_life_benchmark + IFNULL(sum_extended_eul, 0)/12 - (YEAR(CURDATE()) - assets.manufacture_year)) <= ?', params[:months_past_esl_max].to_i)
    end
    past_ulb_counts = past_ulb_counts.count('assets.id')

    total_age = query.sum('YEAR(CURDATE()) - assets.manufacture_year')
    total_mileage = query.sum(:reported_mileage)
    total_condition = query.sum(:reported_condition_rating)

    data = []

    org_label = organization_id_list.count > 1 ? 'All (Filtered) Organizations' : Organization.where(id: organization_id_list).first.short_name

    asset_counts.each do |k, v|
      row = [org_label,*k, v, past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f + 0.5).to_i, (total_condition[k].to_i/v.to_f + 0.5).to_i ]
      unless hide_mileage_column
        row << (total_mileage[k].to_i/v.to_f + 0.5).to_i
      end
      data << row
    end

    return {labels: COMMON_LABELS + (hide_mileage_column ? [] : ['Avg Mileage']), data: data, formats: COMMON_FORMATS + (hide_mileage_column ? [] : [:integer])}
  end

  def clauses
    @clauses
  end

end