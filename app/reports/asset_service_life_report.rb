class AssetServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', '# Past TERM Threshold', '# Past Service Life Calculation', '% Past Service Life Calculation']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :integer, :integer, :percent]

  COMMON_LABELS_WITH_MILEAGE = ['Organization', 'Subtype', 'Quantity','# Past ESL (Mo.)', '# Past ESL (Mi.)', '# Past TERM Threshold', '# Past Service Life Calculation', '% Past Service Life Calculation']
  COMMON_FORMATS_WITH_MILEAGE = [:string, :string, :integer, :integer, :integer, :integer, :integer, :percent]

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

      if params[:months_past_esl_min].to_i > 0
        query = query.where('policy_replacement_year <= (?  - ?/12)', self.new.current_fiscal_year_year, params[:months_past_esl_min].to_i)
      end

      if params[:months_past_esl_max].to_i > 0
        query = query.where('policy_replacement_year >= (? - ?/12)', self.new.current_fiscal_year_year, params[:months_past_esl_max].to_i)
      end

      # Generate queries for each column
      asset_counts = query.count

      # what we really want to check is if the fiscal year of todays date is greater than the fiscal year of the in_service_date + EUL
      past_esl_age = query.where('
    IF(
        in_service_date < STR_TO_DATE(?+YEAR(in_service_date),"%m-%d-%Y"),
        YEAR(DATE_ADD(in_service_date, INTERVAL policy_asset_subtype_rules.min_service_life_months MONTH)) - 1,
        YEAR(DATE_ADD(in_service_date, INTERVAL policy_asset_subtype_rules.min_service_life_months MONTH))
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
        {
            type: :select,
            where: :asset_subtype_id,
            values: [['All', 0]] + AssetSubtype.pluck(:name, :id),
            label: 'Asset Subtype'
        },
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



    org_string = Organization.where(id: organization_id_list).pluck(:short_name).join(' ')
    
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

    if params[:months_past_esl_min].to_i > 0
      @clauses[:months_past_esl_min] = params[:months_past_esl_min].to_i
      query = query.where('policy_replacement_year <= (?  - ?/12)', current_fiscal_year_year, params[:months_past_esl_min].to_i)
    end

    if params[:months_past_esl_max].to_i > 0
      @clauses[:months_past_esl_max] = params[:months_past_esl_max].to_i
      query = query.where('policy_replacement_year >= (? - ?/12)', current_fiscal_year_year, params[:months_past_esl_max].to_i)
    end


    # Generate queries for each column
    asset_counts = query.count

    # what we really want to check is if the fiscal year of todays date is greater than the fiscal year of the in_service_date + EUL
    past_esl_age = query.where('
    IF(
        in_service_date < STR_TO_DATE(?+YEAR(in_service_date),"%m-%d-%Y"),
        YEAR(DATE_ADD(in_service_date, INTERVAL policy_asset_subtype_rules.min_service_life_months MONTH)) - 1,
        YEAR(DATE_ADD(in_service_date, INTERVAL policy_asset_subtype_rules.min_service_life_months MONTH))
    ) < ?', SystemConfig.instance.start_of_fiscal_year+"-", fiscal_year_end_date(Date.today)).count
    past_esl_miles = query.where('reported_mileage > policy_asset_subtype_rules.min_service_life_miles').count unless hide_mileage_column
    past_esl_condition = query.where('reported_condition_rating < policies.condition_threshold').count
    past_esl = query.where('policy_replacement_year < ?', current_fiscal_year_year).count
    
    data = []

    asset_counts.each do |k, v|
     row = ['All (Filtered) Organizations', *k, v, past_esl_age[k].to_i] + (hide_mileage_column ? [] : [past_esl_miles[k].to_i]) + [past_esl_condition[k].to_i, past_esl[k].to_i, (past_esl[k].to_i*100/v.to_f + 0.5).to_i]
     data << row

      puts row.inspect
    end

    return {labels: hide_mileage_column ? COMMON_LABELS : COMMON_LABELS_WITH_MILEAGE, data: data, formats: hide_mileage_column ? COMMON_FORMATS : COMMON_FORMATS_WITH_MILEAGE}
  end

  def get_key(row)
    @has_key ? row[1] : ''
  end

  def get_detail_path(id, key, opts={})
    ext = opts[:format] ? ".#{opts[:format]}" : ''
    "#{id}/details#{ext}?key=#{key}&#{@clauses.to_query}"
  end

  def get_detail_view
    "generic_report_detail"
  end

end