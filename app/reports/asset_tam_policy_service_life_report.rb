class AssetTamPolicyServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Asset Classification Code', 'Quantity','# At or Past ULB/TERM', 'Pcnt', 'Avg Age', 'Avg TERM Condition']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :percent, :integer, :decimal]

  def self.get_underlying_data(organization_id_list, params)

    # Default scope orders by project_id
    query = Asset.operational.joins(:organization, :asset_type, :asset_subtype)
                .joins('LEFT JOIN fta_vehicle_types ON assets.fta_vehicle_type_id = fta_vehicle_types.id')
                .joins('LEFT JOIN fta_support_vehicle_types ON assets.fta_support_vehicle_type_id = fta_support_vehicle_types.id')
                .joins('LEFT JOIN fta_facility_types ON assets.fta_facility_type_id = fta_facility_types.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                .where(assets: {organization_id: organization_id_list})

    fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
    fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

    query = query.where(assets: {asset_type_id: fta_asset_category.asset_types.where.not(class_name: 'Equipment').pluck(:id)})

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: 'activated'}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

      query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = assets.#{asset_level_class.singularize}_id")
    end

    if fta_asset_category.name == 'Facilities'

      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'fta_facility_types.name', 'assets.asset_tag', 'assets.external_id',	'assets.description', 'assets.address1', 'assets.address2', 'assets.city', 'assets.state','assets.zip', 'assets.manufacture_year', 'assets.in_service_date', 'assets.purchase_date', 'assets.purchase_cost', 'IF(assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(assets.pcnt_capital_responsibility > 0, "YES", "NO")',TamPolicy.first ? 'ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)' : '""', 'YEAR(CURDATE()) - assets.manufacture_year','assets.reported_condition_rating']

      labels =['Agency','Asset Type','Asset Subtype',	'FTA Facility Type',	'Asset Tag',	'External ID',	'Name','Address1',	'Address2', 	'City',	'State',	'Zip',	'Year Built','In Service Date', 'Purchase Date',	'Purchase Cost',	'Purchased New', 'Rehabbed Asset?',	'Direct Capital Responsibility','ULB TERM', 	'Age',	'Current Condition (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :integer, :date, :date, :currency, :string, :string, :string, :decimal, :integer, :decimal]
    else
      query = query
                  .joins('INNER JOIN fuel_types ON fuel_types.id = assets.fuel_type_id')
                  .joins('INNER JOIN manufacturers ON manufacturers.id = assets.manufacturer_id')

      if fta_asset_category.name == 'Equipment'
        vehicle_type = 'fta_support_vehicle_types.name'
      else
        vehicle_type = 'CONCAT(fta_vehicle_types.code," - " ,fta_vehicle_types.name)'
      end


      cols = ['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', vehicle_type, 'assets.asset_tag', 'assets.external_id',	'assets.serial_number', 'assets.license_plate', 'assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', 'assets.manufacturer_model', 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'assets.in_service_date', 'assets.purchase_date', 'assets.purchase_cost', 'IF(assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(assets.pcnt_capital_responsibility > 0, "YES", "NO")',(TamPolicy.first ? 'ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)' : '""'), 'YEAR(CURDATE()) - assets.manufacture_year','assets.reported_condition_rating','assets.reported_mileage',(TamPolicy.first ? 'ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12) - (YEAR(CURDATE()) - assets.manufacture_year)' : '""')]

      labels =[ 'Agency','Asset Type','Asset Subtype',	'FTA Vehicle Type',	'Asset Tag',	'External ID',	'VIN','License Plate',	'Manufacturer Year', 	'Manufacturer',	'Model',	'Fuel Type',	'In Service Date', 'Purchase Date',	'Purchase Cost',	'Purchased New', 'Rehabbed Asset?',	'Direct Capital Responsibility','ULB','Age','Current Condition (TERM)',	'Current Mileage (mi.)',	'Useful Life Remaining']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :integer, :integer, :decimal, :integer, :integer]
    end

    puts cols.inspect
    data = query.pluck(*cols)
    puts data[0].inspect

    return {labels: labels, data: data, formats: formats}
  end

  def self.get_detail_data(organization_id_list, params)
    key = params[:key]
    key = key[5..-1].strip if key.index(' - ') == 2
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

      fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
      fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

      query = query.where(assets: {asset_type_id: fta_asset_category.asset_types.where.not(class_name: 'Equipment').pluck(:id)})

      asset_levels = fta_asset_category.asset_levels
      asset_level_class = asset_levels.table_name

      detail_search = Hash.new
      detail_search[asset_level_class] = {id: asset_level_class.classify.constantize.find_by(name: key).id}
      query = query.where(detail_search)

      hide_mileage_column = (fta_asset_category.name == 'Facilities')

      if TamPolicy.first
        policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: 'activated'}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

        if fta_asset_category.name == 'Facilities'
          past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = assets.#{asset_level_class.singularize}_id").where('(ulbs.useful_life_benchmark > assets.reported_condition_rating')
        else
          unless params[:years_past_ulb_min].to_i > 0
            params[:years_past_ulb_min] = 0
          end

          past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = assets.#{asset_level_class.singularize}_id").where('(YEAR(CURDATE()) - assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) >= ?', params[:years_past_ulb_min].to_i)

          if params[:years_past_ulb_max].to_i > 0
            past_ulb_counts = past_ulb_counts.distinct.where('(YEAR(CURDATE()) - assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) <= ?', params[:years_past_ulb_max].to_i)
          end
        end
      else
        past_ulb_counts = query.none
      end


      if fta_asset_category.name == 'Revenue Vehicles'
        past_ulb_counts = past_ulb_counts.group('CONCAT(fta_vehicle_types.code," - " ,fta_vehicle_types.name)')
        query = query.group('CONCAT(fta_vehicle_types.code," - " ,fta_vehicle_types.name)')
      else
        past_ulb_counts = past_ulb_counts.group("#{asset_level_class}.name")
        query = query.group("#{asset_level_class}.name")
      end

      # Generate queries for each column
      asset_counts = query.distinct.count('assets.id')
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

  def get_actions

    @actions = [
        {
            type: :select,
            where: :fta_asset_category_id,
            values: FtaAssetCategory.pluck(:name, :id),
            label: 'Asset Category'
        },
        {
            type: :text_field,
            where: :years_past_ulb_min,
            label: 'Years Past ULB Min'
        },
        {
            type: :text_field,
            where: :years_past_ulb_max,
            label: 'Years Past ULB Max'
        }

    ]
  end

  def get_data(organization_id_list, params)

    @has_key = organization_id_list.count > 1
    @clauses = Hash.new

    data = []

    fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
    @clauses[:fta_asset_category_id] = fta_asset_category_id
    fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

    hide_mileage_column = (['Facilities', 'Infrastructure'].include? fta_asset_category.name)


    if fta_asset_category.asset_types
      # Default scope orders by project_id
      query = Asset.operational.joins(:organization, :asset_subtype)
                  .joins('LEFT JOIN fta_vehicle_types ON assets.fta_vehicle_type_id = fta_vehicle_types.id')
                  .joins('LEFT JOIN fta_support_vehicle_types ON assets.fta_support_vehicle_type_id = fta_support_vehicle_types.id')
                  .joins('LEFT JOIN fta_facility_types ON assets.fta_facility_type_id = fta_facility_types.id')
                  .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id')
                  .where(assets: {organization_id: organization_id_list})


      query = query.where(assets: {asset_type_id: fta_asset_category.asset_types.where.not(class_name: 'Equipment').pluck(:id)})

      asset_levels = fta_asset_category.asset_levels
      asset_level_class = asset_levels.table_name

      if TamPolicy.first
        policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: 'activated'}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

        if fta_asset_category.name == 'Facilities'
          past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = assets.#{asset_level_class.singularize}_id").where('(ulbs.useful_life_benchmark > assets.reported_condition_rating')
        else
          unless params[:years_past_ulb_min].to_i > 0
            params[:years_past_ulb_min] = 0
          end

          past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = assets.organization_id AND ulbs.asset_level_id = assets.#{asset_level_class.singularize}_id").where('(YEAR(CURDATE()) - assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) >= ?', params[:years_past_ulb_min].to_i)

          if params[:years_past_ulb_max].to_i > 0
            past_ulb_counts = past_ulb_counts.distinct.where('(YEAR(CURDATE()) - assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) <= ?', params[:years_past_ulb_max].to_i)
          end
        end

        @clauses[:years_past_ulb_min] = params[:years_past_ulb_min]
        @clauses[:years_past_ulb_max] = params[:years_past_ulb_max]
      else
        past_ulb_counts = query.none
      end


      if fta_asset_category.name == 'Revenue Vehicles'
        past_ulb_counts = past_ulb_counts.group('CONCAT(fta_vehicle_types.code," - " ,fta_vehicle_types.name)')
        query = query.group('CONCAT(fta_vehicle_types.code," - " ,fta_vehicle_types.name)')
      else
        past_ulb_counts = past_ulb_counts.group("#{asset_level_class}.name")
        query = query.group("#{asset_level_class}.name")
      end



      # Generate queries for each column
      asset_counts = query.distinct.count('assets.id')
      past_ulb_counts = past_ulb_counts.count('assets.id')
      total_age = query.sum('YEAR(CURDATE()) - assets.manufacture_year')
      total_mileage = query.sum(:reported_mileage)
      total_condition = query.sum(:reported_condition_rating)

      org_label = organization_id_list.count > 1 ? 'All (Filtered) Organizations' : Organization.where(id: organization_id_list).first.short_name

      asset_counts.each do |k, v|
        row = [org_label,*k, v, past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f + 0.5).to_i, (total_condition[k].to_i/v.to_f + 0.5).to_i ]
        unless hide_mileage_column
          row << (total_mileage[k].to_i/v.to_f + 0.5).to_i
        end
        data << row
      end
    end

    return {labels: COMMON_LABELS + (hide_mileage_column ? [] : ['Avg Mileage']), data: data, formats: COMMON_FORMATS + (hide_mileage_column ? [] : [:integer])}
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