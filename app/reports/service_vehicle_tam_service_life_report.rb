#
# This is one of the new Tam Service Life Report classes
# By profile class (RevenueVehicle, ServiceVehicle, Facility, Track)
#

class ServiceVehicleTamServiceLifeReport < AbstractTamServiceLifeReport

  include FiscalYear
  include TransamFormatHelper

  COMMON_LABELS = ['Organization', 'Asset Classification Code', 'Quantity','TAM Policy Year','ULB Goal','Goal Pcnt','# At or Past ULB', 'Pcnt', 'Avg Age', 'Avg TERM Condition', 'Avg Mileage']
  COMMON_FORMATS = [:string, :string, :integer, :fiscal_year, :integer, :percent, :integer, :percent, :decimal, :decimal, :integer]

  def get_underlying_data(organization_id_list, params)

    typed_asset_class = 'ServiceVehicle'

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
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent'}, service_vehicles: {fta_emergency_contingency_fleet: true})

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    manufacturer_model = 'IF(manufacturer_models.name = "Other",transam_assets.other_manufacturer_model,manufacturer_models.name)'


    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark', 'tam_groups.state', 'pcnt_goal')

      query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id AND fta_type_type = '#{asset_levels.first.class.name}'")
    end

    query = query
                .where.not(service_vehicles: {fta_emergency_contingency_fleet: true})
                .joins("LEFT JOIN fuel_types ON service_vehicles.fuel_type_id = fuel_types.id")
                .joins("LEFT JOIN manufacturers ON transam_assets.manufacturer_id = manufacturers.id")
                .joins("LEFT JOIN serial_numbers ON transam_assets.id = serial_numbers.identifiable_id AND serial_numbers.identifiable_type = 'TransamAsset'")
                .joins('INNER JOIN fta_support_vehicle_types ON transit_assets.fta_type_id = fta_support_vehicle_types.id AND transit_assets.fta_type_type="FtaSupportVehicleType"')

    vehicle_type = 'fta_support_vehicle_types.name'


    if TamPolicy.first
      cols = ['organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name', vehicle_type, 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id',  'serial_numbers.identification', 'service_vehicles.license_plate', 'transam_assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', manufacturer_model, 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")',"'#{TamPolicy.first.fy_year}'",'ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)','ulbs.pcnt_goal','IF(ulbs.state = "pending_activation", "Pending Activation", "Activated")', "YEAR(CURDATE()) - transam_assets.manufacture_year","transam_assets.manufacture_year + ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)","ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12) - (YEAR(CURDATE()) - transam_assets.manufacture_year)",'rating_event.assessed_rating','mileage_event.current_mileage']

      labels =[ 'Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype', 'Asset ID',  'External ID',  'VIN','License Plate',  'Manufacturer Year',  'Manufacturer', 'Model',  'Fuel Type',  'In Service Date', 'Purchase Date', 'Cost (Purchase)',  'Purchased New', 'Rehabbed Asset?', 'Direct Capital Responsibility','TAM Policy Year', 'ULB Goal', 'Goal Pcnt','Tam Policy Status','Age', 'Replacement Year (TAM Policy)', 'Useful Life Remaining','Current Condition (TERM)', 'Current Mileage (mi.)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :fiscal_year, :integer, :percent, :string, :integer, :integer, :integer, :decimal, :integer]

    else
      cols = ['organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name', vehicle_type, 'asset_subtypes.name', 'transam_assets.asset_tag', 'transam_assets.external_id',  'serial_numbers.identification', 'service_vehicles.license_plate', 'transam_assets.manufacture_year', 'CONCAT(manufacturers.code,"-", manufacturers.name)', manufacturer_model, 'CONCAT(fuel_types.code,"-", fuel_types.name)', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")', 'YEAR(CURDATE()) - transam_assets.manufacture_year','rating_event.assessed_rating','mileage_event.current_mileage']

      labels =[ 'Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype', 'Asset ID',  'External ID',  'VIN','License Plate',  'Manufacturer Year',  'Manufacturer', 'Model',  'Fuel Type',  'In Service Date', 'Purchase Date', 'Cost (Purchase)',  'Purchased New', 'Rehabbed Asset?', 'Direct Capital Responsibility','Age','Current Condition (TERM)', 'Current Mileage (mi.)']

      formats = [:string, :string, :string, :string, :string, :string, :string, :string, :integer, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :integer, :decimal, :integer]
    end
    data = query.pluck(*cols)
    
    return {labels: labels, data: data, formats: formats}
  end

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)

    data = []

    single_org_view = params[:has_organization].to_i == 1 || organization_id_list.count == 1

    asset_levels = fta_asset_category.asset_levels
    asset_level_class = asset_levels.table_name

    query = TransitAsset.operational.joins(transam_asset: [:organization, :asset_subtype]).joins(:fta_asset_class)
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id')
                .joins("INNER JOIN #{asset_level_class} as fta_types ON transit_assets.fta_type_id = fta_types.id AND transit_assets.fta_type_type = '#{asset_level_class.classify}'")
                .joins("INNER JOIN `service_vehicles` ON `transit_assets`.`transit_assetible_id` = `service_vehicles`.`id` AND `transit_assets`.`transit_assetible_type` = 'ServiceVehicle'")
                .where(organization_id: organization_id_list, fta_asset_category_id: fta_asset_category.id)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent'}, service_vehicles: {fta_emergency_contingency_fleet: true})

    if TamPolicy.first
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'useful_life_benchmark')

      past_ulb_counts = query.distinct.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id")

      unless params[:years_past_ulb_min].to_i > 0
        params[:years_past_ulb_min] = 0
      end

      past_ulb_counts = past_ulb_counts.where('(YEAR(CURDATE()) - transam_assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) >= ?', params[:years_past_ulb_min].to_i)

      if params[:years_past_ulb_max].to_i > 0
        past_ulb_counts = past_ulb_counts.distinct.where('(YEAR(CURDATE()) - transam_assets.manufacture_year) - (ulbs.useful_life_benchmark + FLOOR(IFNULL(sum_extended_eul, 0)/12)) <= ?', params[:years_past_ulb_max].to_i)
      end
    else
      past_ulb_counts = query.none
    end

    tam_data = grouped_activated_tam_performance_metrics(organization_id_list, fta_asset_category, single_org_view, query.group('organizations.short_name', 'fta_types.name').count)

    if single_org_view
      past_ulb_counts = past_ulb_counts.group('organizations.short_name')
      query = query.group('organizations.short_name')
    end
    past_ulb_counts = past_ulb_counts.group("fta_types.name")
    query = query.group("fta_types.name")

    # Generate queries for each column
    asset_counts = query.distinct.count('transam_assets.id')
    past_ulb_counts = past_ulb_counts.count('transam_assets.id')
    total_age = query.sum('YEAR(CURDATE()) - transam_assets.manufacture_year')

    asset_counts.each do |k, v|
      assets = ServiceVehicle.operational.where(fta_type: asset_level_class.classify.constantize.find_by(name: single_org_view ? k.last : k), organization_id: single_org_view ? Organization.find_by(short_name: k.first) : organization_id_list).where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent'}, service_vehicles: {fta_emergency_contingency_fleet: true})

      total_mileage = MileageUpdateEvent
                      .where(id: AssetEvent
                              .where(base_transam_asset_id: assets.select('transam_assets.id'),
                                     asset_event_type_id: AssetEventType
                                       .find_by(class_name: 'MileageUpdateEvent'))
                              .group(:base_transam_asset_id).maximum(:id).values)
                      .sum(:current_mileage)

      total_condition = ConditionUpdateEvent
                        .where(id: AssetEvent
                                .where(base_transam_asset_id: assets.select('transam_assets.id'),
                                       asset_event_type_id: AssetEventType
                                         .find_by(class_name: 'ConditionUpdateEvent'))
                                .group(:base_transam_asset_id).maximum(:id).values)
                        .sum(:assessed_rating)

      data << (single_org_view ? [] : ['All (Filtered) Organizations']) + [*k, v, TamPolicy.first.try(:fy_year), (tam_data[k] || [])[0], (tam_data[k] || [])[1], past_ulb_counts[k].to_i, (past_ulb_counts[k].to_i*100/v.to_f+0.5).to_i, (total_age[k].to_i/v.to_f).round(1), total_condition/v.to_f, (total_mileage/v.to_f + 0.5).to_i ]
    end

    return {labels: COMMON_LABELS, data: data, formats: COMMON_FORMATS }
  end

  def fta_asset_category
    @fta_asset_category ||= FtaAssetCategory.find_by(name: 'Equipment')
  end

end