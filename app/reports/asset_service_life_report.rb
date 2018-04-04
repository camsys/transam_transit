class AssetServiceLifeReport < AbstractReport

  def self.get_underlying_data(organization_id_list, params)
    "Asset#{RuleSet.find_by(id: params[:rule_set_id]).class_name}ServiceLifeReport".constantize.get_underlying_data(organization_id_list, params)
  end

  def self.get_detail_data(organization_id_list, params)
    "Asset#{RuleSet.find_by(id: params[:rule_set_id]).class_name}ServiceLifeReport".constantize.get_detail_data(organization_id_list, params)
  end
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_actions

    @actions = [
        {
            type: :select,
            where: :rule_set_id,
            values: RuleSet.all.pluck(:name, :id),
            label: 'Policy'
        },
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

    params[:rule_set_id] = RuleSet.first.id if params[:rule_set_id].blank?

    @has_key = organization_id_list.count > 1
    @rule_set_report = "Asset#{RuleSet.find_by(id: params[:rule_set_id]).class_name}ServiceLifeReport".constantize.new

    @rule_set_report.get_data(organization_id_list, params)
  end

  def get_key(row)
    @has_key ? row[1] :  nil
  end

  def get_detail_path(id, key, opts={})

    ext = opts[:format] ? ".#{opts[:format]}" : ''
    @has_key ? "#{id}/details#{ext}?key=#{key}&#{@rule_set_report.clauses.to_query}" : nil
  end

  def get_detail_view
    "generic_report_detail"
  end

end