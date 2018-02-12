class AssetServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', '# Past TERM Threshold', '# Past Service Life Calculation', '% Past Service Life Calculation']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :integer, :integer, :percent]

  COMMON_LABELS_WITH_MILEAGE = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', '# Past ESL (Mi.)', '# Past TERM Threshold', '# Past Service Life Calculation', '% Past Service Life Calculation']
  COMMON_FORMATS_WITH_MILEAGE = [:string, :string, :integer, :integer, :integer, :integer, :integer, :percent]

  def self.get_underlying_data(organization_id_list, params)

    if params[:asset_type_id].to_i > 0
      asset_type =  AssetType.find_by(id: params[:asset_type_id])
      if asset_type.class_name == 'Vehicle'
        query = asset_type.class_name.constantize.operational.joins(:organization, :asset_subtype)
                .includes(:asset_type, :fta_vehicle_type, :manufacturer, :fuel_type)
                .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                .joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                .where(organization_id: organization_id_list)



        cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'fta_vehicle_types.name', 'assets.asset_tag', 'assets.external_id',	'assets.serial_number', 'assets.license_plate', 'assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', 'assets.manufacturer_model', 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'assets.in_service_date', 'assets.purchase_date', 'assets.purchase_cost', 'assets.purchased_new',"#{self.new.current_fiscal_year_year} - IF(in_service_date < STR_TO_DATE(#{SystemConfig.instance.start_of_fiscal_year}+YEAR(in_service_date),'%m-%d-%Y'),YEAR(in_service_date) - 1,YEAR(in_service_date))",'IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months)', 'assets.reported_mileage','policy_asset_subtype_rules.min_service_life_miles', 'assets.reported_condition_rating', 'policies.condition_threshold']

        labels =[ 'Agency','Asset Type','Asset Subtype',	'FTA Vehicle Type',	'Asset Tag',	'External ID',	'VIN','License Plate',	'Manufacturer Year', 	'Manufacturer',	'Model',	'Fuel Type',	'In Service Date', 'Purchase Date',	'Purchase Cost',	'Purchased New',	'Current Age (mo.)', 	'Policy ESL (mo.)',	'Current Mileage (mi.)',	'Policy ESL (mi.)',	'Current Condition (TERM)',	'Policy Condition Threshold (TERM)']

        formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :boolean, :integer, :integer, :integer, :integer, :decimal, :decimal]
      end

      if params[:asset_subtype_id].to_i > 0
        query = query.where(assets: {asset_subtype_id: params[:asset_subtype_id]})
      end

      data = query.pluck(*cols)

      return {labels: labels, data: data, formats: formats}
    else
      return {labels: ['Please select only one asset type at a time. (Currently can only export Rev. Vehicle data.'], data: [], formats: []}
    end
  end

  def self.get_detail_data(organization_id_list, params)
    key = params[:key]
    data = []
    unless key.blank?

      query = Asset.operational.joins(:organization, :asset_subtype)
                  .joins('INNER JOIN policies ON policies.organization_id = organizations.id')
                  .joins('INNER JOIN policy_asset_subtype_rules ON policy_asset_subtype_rules.policy_id = policies.id AND policy_asset_subtype_rules.asset_subtype_id = asset_subtypes.id')
                  .where(organization_id: organization_id_list)
                  .group('organizations.short_name', 'asset_subtypes.name')

      hide_mileage_column = false
      unless ['Vehicle', 'SupportVehicle'].include? AssetSubtype.find_by(name: key).asset_type.class_name
        hide_mileage_column = true
      end
      query = query.where(asset_subtypes: {name: key})

      # Generate queries for each column
      asset_counts = query.count

      if params[:months_past_esl_min].to_i > 0
        query = query.where('policy_replacement_year <= (?  - ?/12)', self.new.current_fiscal_year_year, params[:months_past_esl_min].to_i)
      end

      if params[:months_past_esl_max].to_i > 0
        query = query.where('policy_replacement_year >= (? - ?/12)', self.new.current_fiscal_year_year, params[:months_past_esl_max].to_i)
      end

      # what we really want to check is if the fiscal year of todays date is greater than the fiscal year of the in_service_date + EUL
      past_esl_age = query.joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                         .where('
      IF(
        in_service_date < STR_TO_DATE(?+YEAR(in_service_date),"%m-%d-%Y"),
        YEAR(DATE_ADD(in_service_date, INTERVAL
        (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) MONTH)) - 1,
        YEAR(DATE_ADD(in_service_date, INTERVAL
        (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) +IFNULL(sum_extended_eul, 0)) MONTH))
      ) < ?', SystemConfig.instance.start_of_fiscal_year+"-", self.new.fiscal_year_end_date(Date.today)).count
      past_esl_miles = query.where('reported_mileage > policy_asset_subtype_rules.min_service_life_miles').count unless hide_mileage_column
      past_esl_condition = query.where('reported_condition_rating < policies.condition_threshold').count
      past_esl = query.where('policy_replacement_year < ?', self.new.current_fiscal_year_year).count

      asset_counts.each do |k, v|
        row = [*k, v, past_esl_age[k].to_i] + (hide_mileage_column ? [] : [past_esl_miles[k].to_i]) + [past_esl_condition[k].to_i, past_esl[k].to_i, (past_esl[k].to_i*100/v.to_f + 0.5).to_i]
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
            values: [['All', 0]] + AssetType.pluck(:name, :id),
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
                .where(organization_id: organization_id_list).group('asset_subtypes.name')

    hide_mileage_column = false
    if params[:asset_type_id].to_i > 0

      unless ['Vehicle', 'SupportVehicle'].include? AssetType.find_by(id: params[:asset_type_id]).class_name
        hide_mileage_column = true
      end

      query = query.where(assets: {asset_type_id: params[:asset_type_id]})
    end

    if params[:asset_subtype_id].to_i > 0
      query = query.where(assets: {asset_subtype_id: params[:asset_subtype_id]})
    end

    # Generate queries for each column
    asset_counts = query.count

    if params[:months_past_esl_min].to_i > 0
      @clauses[:months_past_esl_min] = params[:months_past_esl_min].to_i
      query = query.where('policy_replacement_year <= (?  - ?/12)', current_fiscal_year_year, params[:months_past_esl_min].to_i)
    end

    if params[:months_past_esl_max].to_i > 0
      @clauses[:months_past_esl_max] = params[:months_past_esl_max].to_i
      query = query.where('policy_replacement_year >= (? - ?/12)', current_fiscal_year_year, params[:months_past_esl_max].to_i)
    end

    # what we really want to check is if the fiscal year of todays date is greater than the fiscal year of the in_service_date + EUL
    past_esl_age = query
                       .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                       .where('
      IF(
        in_service_date < STR_TO_DATE(?+YEAR(in_service_date),"%m-%d-%Y"),
        YEAR(DATE_ADD(in_service_date, INTERVAL
        (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) + IFNULL(sum_extended_eul, 0)) MONTH)) - 1,
        YEAR(DATE_ADD(in_service_date, INTERVAL
        (IF(assets.purchased_new, policy_asset_subtype_rules.min_service_life_months,policy_asset_subtype_rules.min_used_purchase_service_life_months) +IFNULL(sum_extended_eul, 0)) MONTH))
      ) < ?', SystemConfig.instance.start_of_fiscal_year+"-", fiscal_year_end_date(Date.today)).count
    past_esl_miles = query.where('reported_mileage > policy_asset_subtype_rules.min_service_life_miles').count unless hide_mileage_column
    past_esl_condition = query.where('reported_condition_rating < policies.condition_threshold').count
    past_esl = query.where('policy_replacement_year < ?', current_fiscal_year_year).count
    
    data = []

    org_label = organization_id_list.count > 1 ? 'All (Filtered) Organizations' : Organization.where(id: organization_id_list).first.short_name

    asset_counts.each do |k, v|
     row = [org_label, *k, v, past_esl_age[k].to_i] + (hide_mileage_column ? [] : [past_esl_miles[k].to_i]) + [past_esl_condition[k].to_i, past_esl[k].to_i, (past_esl[k].to_i*100/v.to_f + 0.5).to_i]
     data << row

      #puts row.inspect
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