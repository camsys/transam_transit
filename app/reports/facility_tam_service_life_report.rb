#
# This is one of the new Tam Service Life Report classes
# By profile class (RevenueVehicle, ServiceVehicle, Facility, Track)
#

class FacilityTamServiceLifeReport < AbstractTamServiceLifeReport

  COMMON_LABELS = ['Organization', 'Asset Classification Code', 'Quantity','TAM Policy Year','TERM Goal','Goal Pcnt','# At or Past ULB', 'Pcnt', 'Avg Age', 'Avg TERM Condition']
  COMMON_FORMATS = [:string, :string, :integer, :fiscal_year, :decimal, :percent,:integer, :percent, :decimal, :decimal]

  def get_underlying_data(organization_id_list, params)

    typed_asset_class = fta_asset_category.fta_asset_classes.first.class_name

    query = typed_asset_class.constantize.operational
                .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                .joins('INNER JOIN fta_asset_categories ON transit_assets.fta_asset_category_id = fta_asset_categories.id')
                .joins('INNER JOIN fta_asset_classes ON transit_assets.fta_asset_class_id = fta_asset_classes.id')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id')
                .joins('LEFT JOIN manufacturer_models ON transam_assets.manufacturer_model_id = manufacturer_models.id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_milage ON recent_milage.base_transam_asset_id = transam_assets.id AND recent_milage.asset_event_name = "MileageUpdateEvent"')
                .joins('LEFT JOIN asset_events AS mileage_event ON mileage_event.id = recent_milage.asset_event_id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_rating ON recent_rating.base_transam_asset_id = transam_assets.id AND recent_rating.asset_event_name = "ConditionUpdateEvent"')
                .joins('LEFT JOIN asset_events AS rating_event ON rating_event.id = recent_rating.asset_event_id')
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category.id)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent'})

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    manufacturer_model = 'IF(manufacturer_models.name = "Other",transam_assets.other_manufacturer_model,manufacturer_models.name)'

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark', 'tam_groups.state', 'pcnt_goal')

      query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_asset_class_id")
    end

    query = query
                .joins('INNER JOIN fta_facility_types ON transit_assets.fta_type_id = fta_facility_types.id AND transit_assets.fta_type_type="FtaFacilityType"')

    cols = ['transam_assets.object_key', 'organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name','fta_facility_types.name', 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id', 'transam_assets.description', 'facilities.address1', 'facilities.address2', 'facilities.city', 'facilities.state','facilities.zip', 'transam_assets.manufacture_year', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")', 'YEAR(CURDATE()) - transam_assets.manufacture_year','rating_event.assessed_rating']

    labels =['Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype',  'Asset ID',  'External ID',  'Name','Address1',  'Address2',   'City', 'State',  'Zip',  'Year Built','In Service Date', 'Purchase Date',  'Cost (Purchase)',  'Purchased New', 'Rehabbed Asset?', 'Direct Capital Responsibility' , 'TAM Policy Year', 'TERM Goal', 'Goal Pcnt','Tam Policy Status', 'Age',  'Current Condition (TERM)']

    formats = [:string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :integer, :date, :date, :currency, :string, :string, :string, :fiscal_year, :decimal, :percent, :string ,:decimal, :decimal]

    result = query.pluck(*cols)

    data = []
    result.each do |row|
      asset = TransamAsset.get_typed_asset(TransamAsset.find_by(object_key: row[0]))
      if asset.tam_performance_metric
        data << (row[1..-3] + [asset.tam_performance_metric.tam_group.tam_policy.fy_year,asset.useful_life_benchmark,asset.tam_performance_metric.pcnt_goal, asset.tam_performance_metric.tam_group.state.humanize.titleize] + row[-2..-1])
      else
        data << (row[1..-3] + [nil,asset.useful_life_benchmark, nil, nil] + row[-2..-1])
      end
    end
    
    return {labels: labels, data: data, formats: formats}
  end


  def get_data(organization_id_list, params)

    data = []

    single_org_view = params[:has_organization].to_i == 1 || organization_id_list.count == 1

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    query = TransitAsset.operational.joins(transam_asset: [:organization, :asset_subtype]).joins(:fta_asset_class)
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id')
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category.id)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent'})

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

      if fta_asset_category.name == 'Facilities'
        past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_asset_class_id")
      else
        past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id")
      end

    else
      past_ulb_counts = query.none
    end

    tam_data = grouped_activated_tam_performance_metrics(organization_id_list, fta_asset_category, single_org_view, query.group('organizations.short_name', 'fta_asset_classes.name'))


    if single_org_view
      result = Hash.new
      TransitAsset.unscoped.joins({transam_asset: :organization}, :fta_asset_class).where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category.id).pluck('organizations.short_name', 'fta_asset_classes.name').each do |x|
        result[x] = 0
      end
      past_ulb_counts.each do |row|
        result[[row.organization.short_name, row.fta_asset_class.name]] += 1 if (row.useful_life_benchmark || 0) > (row.reported_condition_rating || 0)
      end
      query = query.group("organizations.short_name")
    else
      result = Hash[ *FtaAssetClass.where(id: TransitAsset.where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category.id).pluck(:fta_asset_class_id)).collect { |v| [ v.name, 0 ] }.flatten ]
      past_ulb_counts.each do |row|
        result[row.fta_asset_class.name] += 1 if (row.useful_life_benchmark || 0) > (row.reported_condition_rating || 0)
      end
    end
    past_ulb_counts = result
    query = query.group("fta_asset_classes.name")


    # Generate queries for each column
    asset_counts = query.distinct.count('transam_assets.id')
    total_age = query.sum('YEAR(CURDATE()) - transam_assets.manufacture_year')

    asset_counts.each do |k, v|
      assets = Facility.where(fta_asset_class: FtaAssetClass.find_by(name: single_org_view ? k.last : k), organization_id: single_org_view ? Organization.find_by(short_name: k.first) : organization_id_list).where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent'})

      #total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'TransamAsset',transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)
      total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(base_transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'ConditionUpdateEvent').select(:asset_event_id)).sum(:assessed_rating)



      data << (single_org_view ? [] : ['All (Filtered) Organizations']) + [*k, v, TamPolicy.first.try(:fy_year), (tam_data[k] || [])[0], (tam_data[k] || [])[1], past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f).round(1), total_condition/v.to_f ]
    end

    return {labels: COMMON_LABELS, data: data, formats: COMMON_FORMATS}
  end


  def fta_asset_category
    @fta_asset_category ||= FtaAssetCategory.find_by(name: 'Facilities')
  end
end