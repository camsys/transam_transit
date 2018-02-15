class AssetServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', 'Pcnt', '# Past TERM Threshold', 'Pcnt']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :percent, :integer, :percent]

  COMMON_LABELS_WITH_MILEAGE = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', 'Pcnt','# Past ESL (Mi.)', 'Pcnt', '# Past TERM Threshold', 'Pcnt']
  COMMON_FORMATS_WITH_MILEAGE = [:string, :string, :integer, :integer, :percent, :integer, :percent, :integer, :percent]

  def self.get_underlying_data(organization_id_list, params)

    asset_type_id = params[:asset_type_id].to_i > 0 ? params[:asset_type_id].to_i : 1 # default to rev vehicles
    asset_type =  AssetType.find_by(id: asset_type_id)

    query = asset_type.class_name.constantize.operational.joins(:organization, :asset_subtype)
                .includes(:asset_type)
                .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                .joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                .where(organization_id: organization_id_list)

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

      query = Asset.operational.joins(:organization, :asset_subtype)
                  .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                  .joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')
                  .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                  .where(organization_id: organization_id_list)
                  .group('organizations.short_name', 'asset_subtypes.name')

      hide_mileage_column = false
      unless ['Vehicle', 'SupportVehicle'].include? AssetSubtype.find_by(name: key).asset_type.class_name
        hide_mileage_column = true
      end
      query = query.where(asset_subtypes: {name: key})

      # Generate queries for each column
      asset_counts = query.distinct.count('assets.id')

      if params[:months_past_esl_max].to_i > 0
        # if theres a max there must be a min
        params[:months_past_esl_min] = 1 unless params[:months_past_esl_min].to_i > 0

        query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) <= (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_max].to_i)
      end

      if params[:months_past_esl_min].to_i > 0
        query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) >= (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_min].to_i)
      end

      # we don't calculate age like we do in the policy as the policy is for its replacement by capital planning
      # age in this report is the months diff from today and an assets in service date
      unless params[:months_past_esl_min].to_i > 0
        past_esl_age = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) > (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0))', Date.today, Date.today).distinct.count('assets.id')
      else
        past_esl_age = query.distinct.count('assets.id')
      end
      past_esl_miles = query.where('reported_mileage > policy_asset_subtype_rules.min_service_life_miles').distinct.count('assets.id') unless hide_mileage_column
      past_esl_condition = query.where('reported_condition_rating < policies.condition_threshold').distinct.count('assets.id')

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
            where: :asset_type_id,
            values: AssetType.order(:id).pluck(:name, :id),
            label: 'Asset Type'
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
            label: 'Months Past ESL min'
        },
        {
            type: :text_field,
            where: :months_past_esl_max,
            label: 'Months Past ESL max'
        }

    ]
  end
  
  def get_data(organization_id_list, params)

    @has_key = organization_id_list.count > 1
    @clauses = Hash.new
    
    # Default scope orders by project_id
    query = Asset.operational.joins(:organization, :asset_subtype)
                .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                .joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                .where(organization_id: organization_id_list).group('asset_subtypes.name')

    hide_mileage_column = false
    asset_type_id = params[:asset_type_id].to_i > 0 ? params[:asset_type_id].to_i : 1 # rev vehicles if none selected


    unless ['Vehicle', 'SupportVehicle'].include? AssetType.find_by(id: asset_type_id).class_name
      hide_mileage_column = true
    end

    query = query.where(assets: {asset_type_id: asset_type_id})

    if params[:asset_subtype_id].to_i > 0
      query = query.where(assets: {asset_subtype_id: params[:asset_subtype_id]})
    end

    # Generate queries for each column
    asset_counts = query.distinct.count('assets.id')

    if params[:months_past_esl_max].to_i > 0
      # if theres a max there must be a min
      params[:months_past_esl_min] = 1 unless params[:months_past_esl_min].to_i > 0

      @clauses[:months_past_esl_max] = params[:months_past_esl_max].to_i
      query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) <= (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_max].to_i)
    end

    if params[:months_past_esl_min].to_i > 0
      @clauses[:months_past_esl_min] = params[:months_past_esl_min].to_i
      query = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) >= (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) + ?', Date.today, Date.today, params[:months_past_esl_min].to_i)
    end



    # we don't calculate age like we do in the policy as the policy is for its replacement by capital planning
    # age in this report is the months diff from today and an assets in service date

    unless params[:months_past_esl_min].to_i > 0
      past_esl_age = query.where('(YEAR(?)*12+MONTH(?)-YEAR(in_service_date)*12-MONTH(in_service_date)) > (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0))', Date.today, Date.today).distinct.count('assets.id')
    else
      past_esl_age = query.distinct.count('assets.id')
    end
    past_esl_miles = query.where('reported_mileage > policy_asset_subtype_rules.min_service_life_miles').distinct.count('assets.id') unless hide_mileage_column
    past_esl_condition = query.where('reported_condition_rating < policies.condition_threshold').distinct.count('assets.id')

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