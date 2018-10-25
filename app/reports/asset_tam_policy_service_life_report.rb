class AssetTamPolicyServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Asset Classification Code', 'Quantity','# At or Past ULB/TERM', 'Pcnt', 'Avg Age', 'Avg TERM Condition']
  COMMON_FORMATS = [:string, :string, :integer, :integer, :percent, :decimal, :decimal]

  def self.get_underlying_data(organization_id_list, params)

    fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
    fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

    if fta_asset_category.name == 'Infrastructure'
      return InfrastructureTamPolicyServiceLifeReport.get_underlying_data(organization_id_list, params)
    end

    if fta_asset_category.name  == 'Equipment'
      typed_asset_class = 'ServiceVehicle'
    else
      typed_asset_class = fta_asset_category.fta_asset_classes.first.class_name
    end

    query = typed_asset_class.constantize.operational
                .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                .joins('INNER JOIN fta_asset_categories ON transit_assets.fta_asset_category_id = fta_asset_categories.id')
                .joins('INNER JOIN fta_asset_classes ON transit_assets.fta_asset_class_id = fta_asset_classes.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, transam_asset_id FROM asset_events GROUP BY transam_asset_id) as rehab_events ON rehab_events.transam_asset_id = transam_assets.id')
                .joins('LEFT JOIN manufacturer_models ON transam_assets.manufacturer_model_id = manufacturer_models.id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_milage ON recent_milage.transam_asset_id = transam_assets.id AND recent_milage.asset_event_name = "Mileage"')
                .joins('LEFT JOIN asset_events AS mileage_event ON mileage_event.id = recent_milage.asset_event_id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_rating ON recent_rating.transam_asset_id = transam_assets.id AND recent_rating.asset_event_name = "Condition"')
                .joins('LEFT JOIN asset_events AS rating_event ON rating_event.id = recent_rating.asset_event_id')
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'Component'})

    unless fta_asset_category.name == 'Facilities'
      query = query.joins("INNER JOIN `service_vehicles` ON `transit_assets`.`transit_assetible_id` = `service_vehicles`.`id` AND `transit_assets`.`transit_assetible_type` = 'ServiceVehicle'").where.not(service_vehicles: {fta_emergency_contingency_fleet: true})
    end

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark', 'tam_groups.state')

      query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id AND fta_type_type = '#{asset_levels.first.class.name}'")
    end

    manufacturer_model = 'IF(manufacturer_models.name = "Other",transam_assets.other_manufacturer_model,manufacturer_models.name)'

    if typed_asset_class.include? 'Facility'
      query = query
                  .joins('INNER JOIN fta_facility_types ON transit_assets.fta_type_id = fta_facility_types.id AND transit_assets.fta_type_type="FtaFacilityType"')
        
      cols = ['transam_assets.object_key', 'organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name','fta_facility_types.name', 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id', 'transam_assets.description', 'facilities.address1', 'facilities.address2', 'facilities.city', 'facilities.state','facilities.zip', 'transam_assets.manufacture_year', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")', 'YEAR(CURDATE()) - YEAR(in_service_date)','rating_event.assessed_rating']

      labels =['Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype',  'Asset ID',  'External ID',  'Name','Address1',  'Address2',   'City', 'State',  'Zip',  'Year Built','In Service Date', 'Purchase Date',  'Purchase Cost',  'Purchased New', 'Rehabbed Asset?', 'Direct Capital Responsibility', 'TERM - TAM Policy', 'TAM Policy Year', 'Tam Policy Status', 'Age',  'Current Condition (TERM)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :integer, :date, :date, :currency, :string, :string, :string, :integer, :decimal, :decimal]

      result = query.pluck(*cols)

      data = []
      result.each do |row|
        asset = TransamAsset.get_typed_asset(TransamAsset.find_by(object_key: row[0]))
        data << (row[1..-3] + [asset.useful_life_benchmark, asset.tam_performance_metric.tam_policy.fy_year, asset.tam_performance_metric.state.humanize.titleize] + row[-2..-1])
      end

    else
      query = query
                  .joins("LEFT JOIN fuel_types ON service_vehicles.fuel_type_id = fuel_types.id")
                  .joins("LEFT JOIN manufacturers ON transam_assets.manufacturer_id = manufacturers.id")
                  .joins("LEFT JOIN serial_numbers ON transam_assets.id = serial_numbers.identifiable_id AND serial_numbers.identifiable_type = 'TransamAsset'")

      if typed_asset_class.include? 'Equipment'
        query = query
                    .joins('INNER JOIN fta_support_vehicle_types ON transit_assets.fta_type_id = fta_support_vehicle_types.id AND transit_assets.fta_type_type="FtaSupportVehicleType"')
        
        vehicle_type = 'fta_support_vehicle_types.name'
      else
        query = query
                    .joins('INNER JOIN fta_vehicle_types ON transit_assets.fta_type_id = fta_vehicle_types.id AND transit_assets.fta_type_type="FtaVehicleType"')
        
        vehicle_type = 'CONCAT(fta_vehicle_types.code," - " ,fta_vehicle_types.name)'
      end


      if TamPolicy.first
      cols = ['organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name', vehicle_type, 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id',  'serial_numbers.identification', 'service_vehicles.license_plate', 'transam_assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', manufacturer_model, 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")','ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)',"'#{TamPolicy.first.fy_year+1}'",'IF(ulbs.state = "pending_activation", "Pending Activation", "Activated")', "#{TamPolicy.first.fy_year+1} - transam_assets.manufacture_year","ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12) - (#{TamPolicy.first.fy_year+1} - transam_assets.manufacture_year)",'rating_event.assessed_rating','mileage_event.current_mileage']

        labels =[ 'Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype', 'Asset ID',  'External ID',  'VIN','License Plate',  'Manufacturer Year',  'Manufacturer', 'Model',  'Fuel Type',  'In Service Date', 'Purchase Date', 'Purchase Cost',  'Purchased New', 'Rehabbed Asset?', 'Direct Capital Responsibility','ULB - TAM Policy','TAM Policy Year', 'Tam Policy Status','Age',  'Useful Life Remaining','Current Condition (TERM)', 'Current Mileage (mi.)']

        formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :integer, :integer, :decimal, :integer, :integer]
      else
        cols = ['organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name', vehicle_type, 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id',  'serial_numbers.identification', 'service_vehicles.license_plate', 'transam_assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', manufacturer_model, 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")', 'YEAR(CURDATE()) - transam_assets.manufacture_year','rating_event.assessed_rating','mileage_event.current_mileage']

        labels =[ 'Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype', 'Asset ID',  'External ID',  'VIN','License Plate',  'Manufacturer Year',  'Manufacturer', 'Model',  'Fuel Type',  'In Service Date', 'Purchase Date', 'Purchase Cost',  'Purchased New', 'Rehabbed Asset?', 'Direct Capital Responsibility','Age','Current Condition (TERM)', 'Current Mileage (mi.)']

        formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :integer, :decimal, :integer]
      end
      data = query.pluck(*cols)
    end
    
    return {labels: labels, data: data, formats: formats}
  end

  def self.get_detail_data(organization_id_list, params)
    key = params[:key]
    key = key[5..-1].strip if key.index(' - ') == 2
    data = []
    unless key.blank?

      fta_asset_category_id = params[:fta_asset_category_id].to_i > 0 ? params[:fta_asset_category_id].to_i : 1 # rev vehicles if none selected
      fta_asset_category = FtaAssetCategory.find_by(id: fta_asset_category_id)

      if fta_asset_category.name == 'Infrastructure'
        return InfrastructureTamPolicyServiceLifeReport.get_detail_data(organization_id_list, params)
      end

      asset_levels = fta_asset_category.asset_levels
      asset_level_class = asset_levels.table_name

      query = TransitAsset.operational.joins(transam_asset: [:organization, :asset_subtype]).joins(:fta_asset_class)
                  .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = transam_assets.id')
                  .joins("INNER JOIN #{asset_level_class} as fta_types ON transit_assets.fta_type_id = fta_types.id AND transit_assets.fta_type_type = '#{asset_level_class.classify}'")
                  .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id)
                  .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'Component'})

      unless fta_asset_category.name == 'Facilities'
        query = query.joins("INNER JOIN `service_vehicles` ON `transit_assets`.`transit_assetible_id` = `service_vehicles`.`id` AND `transit_assets`.`transit_assetible_type` = 'ServiceVehicle'").where.not(service_vehicles: {fta_emergency_contingency_fleet: true})
      end

      query = query.where(fta_type: asset_level_class.classify.constantize.find_by(name: key))

      hide_mileage_column = (fta_asset_category.name == 'Facilities')

      if TamPolicy.first
        policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

        past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id")

        unless fta_asset_category.name == 'Facilities'
          unless params[:years_past_ulb_min].to_i > 0
            params[:years_past_ulb_min] = 0
          end

          past_ulb_counts = past_ulb_counts.where('(YEAR(CURDATE()) - transam_assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) >= ?', params[:years_past_ulb_min].to_i)

          if params[:years_past_ulb_max].to_i > 0
            past_ulb_counts = past_ulb_counts.distinct.where('(YEAR(CURDATE()) - transam_assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) <= ?', params[:years_past_ulb_max].to_i)
          end
        end
      else
        past_ulb_counts = query.none
      end

      if fta_asset_category.name == 'Revenue Vehicles'
        past_ulb_counts = past_ulb_counts.group('organizations.short_name').group('CONCAT(fta_types.code," - " ,fta_types.name)')
        query = query.group('organizations.short_name').group('CONCAT(fta_types.code," - " ,fta_types.name)')
      elsif fta_asset_category.name == 'Facilities'
        result = Hash[ *FtaAssetClass.where(id: TransitAsset.where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id).pluck(:fta_asset_class_id)).collect { |v| [ v.name, 0 ] }.flatten ]
        past_ulb_counts.each do |row|
          result[row.fta_asset_class.name] += 1 if (row.useful_life_benchmark || 0) > (row.reported_condition_rating || 0)
        end
        past_ulb_counts = result
        query = query.group("fta_asset_classes.name")
      else
        past_ulb_counts = past_ulb_counts.group("fta_types.name")
        query = query.group("fta_types.name")
      end

      # Generate queries for each column
      asset_counts = query.distinct.count('transam_assets.id')
      past_ulb_counts = past_ulb_counts.count('transam_assets.id') unless fta_asset_category.name == 'Facilities'
      total_age = query.sum('YEAR(CURDATE()) - transam_assets.manufacture_year')

      asset_counts.each do |k, v|
        assets = TransitAsset.joins(transam_asset: :organization).where(organizations: {short_name: k[0]}).where(fta_type: asset_level_class.classify.constantize.find_by(name: key))

        total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'TransamAsset', transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)
        total_mileage = MileageUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'ServiceVehicle', transam_asset_id: assets.select('service_vehicles.id'), asset_event_name: 'Mileage').select(:asset_event_id)).sum(:current_mileage)


        row = [*k, v, past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f).round(1), total_condition/v.to_f ]
        unless hide_mileage_column
          row << (total_mileage/v.to_f + 0.5).to_i
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

    categories = FtaAssetCategory.pluck(:name, :id).map{|x|
      if x[0] == 'Equipment'
        ['Equipment - Service Vehicles', x[1]]
      elsif x[0] == 'Infrastructure'
        ['Infrastructure - Track', x[1]]
      else
        x
      end
    }

    @actions = [
        {
            type: :select,
            where: :fta_asset_category_id,
            values: categories,
            label: 'Asset Category'
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

    if fta_asset_category.name == 'Infrastructure'
      return InfrastructureTamPolicyServiceLifeReport.new.get_data(organization_id_list, params)
    end

    hide_mileage_column = (['Facilities', 'Infrastructure'].include? fta_asset_category.name)

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    query = TransitAsset.operational.joins(transam_asset: [:organization, :asset_subtype]).joins(:fta_asset_class)
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = transam_assets.id')
                .joins("INNER JOIN #{asset_level_class} as fta_types ON transit_assets.fta_type_id = fta_types.id AND transit_assets.fta_type_type = '#{asset_level_class.classify}'")
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'Component'})

    unless fta_asset_category.name == 'Facilities'
      query = query.joins("INNER JOIN `service_vehicles` ON `transit_assets`.`transit_assetible_id` = `service_vehicles`.`id` AND `transit_assets`.`transit_assetible_type` = 'ServiceVehicle'").where.not(service_vehicles: {fta_emergency_contingency_fleet: true})
    end

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

      past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id")

      unless fta_asset_category.name == 'Facilities'
        unless params[:years_past_ulb_min].to_i > 0
          params[:years_past_ulb_min] = 0
        end

        past_ulb_counts = past_ulb_counts.where('(YEAR(CURDATE()) - transam_assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) >= ?', params[:years_past_ulb_min].to_i)

        if params[:years_past_ulb_max].to_i > 0
          past_ulb_counts = past_ulb_counts.distinct.where('(YEAR(CURDATE()) - transam_assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) <= ?', params[:years_past_ulb_max].to_i)
        end
      end

      @clauses[:years_past_ulb_min] = params[:years_past_ulb_min]
      @clauses[:years_past_ulb_max] = params[:years_past_ulb_max]
    else
      past_ulb_counts = query.none
    end


    if fta_asset_category.name == 'Revenue Vehicles'
      past_ulb_counts = past_ulb_counts.group('CONCAT(fta_types.code," - " ,fta_types.name)')
      query = query.group('CONCAT(fta_types.code," - " ,fta_types.name)')
    elsif fta_asset_category.name == 'Facilities'
      result = Hash[ *FtaAssetClass.where(id: TransitAsset.where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category_id).pluck(:fta_asset_class_id)).collect { |v| [ v.name, 0 ] }.flatten ]
      past_ulb_counts.each do |row|
        result[row.fta_asset_class.name] += 1 if (row.useful_life_benchmark || 0) > (row.reported_condition_rating || 0)
      end
      past_ulb_counts = result
      query = query.group("fta_asset_classes.name")
    else
      past_ulb_counts = past_ulb_counts.group("fta_types.name")
      query = query.group("fta_types.name")
    end


    # Generate queries for each column
    asset_counts = query.distinct.count('transam_assets.id')
    past_ulb_counts = past_ulb_counts.count('transam_assets.id') unless fta_asset_category.name == 'Facilities'
    total_age = query.sum('YEAR(CURDATE()) - transam_assets.manufacture_year')

    org_label = organization_id_list.count > 1 ? 'All (Filtered) Organizations' : Organization.where(id: organization_id_list).first.short_name

    asset_counts.each do |k, v|
      assets = TransitAsset.where(fta_type: asset_level_class.classify.constantize.find_by(name: k.split('-').last.strip), organization_id: organization_id_list)

      total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'TransamAsset',transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)
      total_mileage = MileageUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'ServiceVehicle', transam_asset_id: assets.select('service_vehicles.id'), asset_event_name: 'Mileage').select(:asset_event_id)).sum(:current_mileage)


      row = [org_label,*k, v, past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f).round(1), total_condition/v.to_f ]
      unless hide_mileage_column
        row << (total_mileage/v.to_f + 0.5).to_i
      end
      data << row
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