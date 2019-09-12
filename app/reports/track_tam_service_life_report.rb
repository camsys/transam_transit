#
# This is one of the new Tam Service Life Report classes
# By profile class (RevenueVehicle, ServiceVehicle, Facility, Track)
#

class TrackTamServiceLifeReport < AbstractTamServiceLifeReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Primary Mode', 'Line Length','TAM Policy Year','Goal Pcnt','Active Performance Restrictions', 'Pcnt', 'Avg Age', 'Avg TERM Condition']
  COMMON_FORMATS = [:string, :string, :decimal, :fiscal_year, :percent, :decimal, :percent, :decimal, :decimal]

  def get_underlying_data(organization_id_list, params)

    query = Track.operational.joins(:infrastructure_segment_type, :infrastructure_division, :infrastructure_subdivision, :infrastructure_track)
                .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                .joins('INNER JOIN fta_asset_categories ON transit_assets.fta_asset_category_id = fta_asset_categories.id')
                .joins('INNER JOIN fta_asset_classes ON transit_assets.fta_asset_class_id = fta_asset_classes.id')
                .joins('INNER JOIN fta_track_types ON transit_assets.fta_type_id = fta_track_types.id AND transit_assets.fta_type_type = "FtaTrackType"')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_rating ON recent_rating.base_transam_asset_id = transam_assets.id AND recent_rating.asset_event_name = "ConditionUpdateEvent"')
                .joins('LEFT JOIN asset_events AS rating_event ON rating_event.id = recent_rating.asset_event_id')
                .joins('LEFT JOIN recent_asset_events_views AS performance_restriction ON performance_restriction.base_transam_asset_id = transam_assets.id AND performance_restriction.asset_event_name = "Performance Restrictions"')
                .joins('LEFT JOIN asset_events AS restriction_event ON restriction_event.id = performance_restriction.asset_event_id')
                .joins("LEFT JOIN (SELECT base_transam_asset_id, COUNT(*) as count_all FROM asset_events WHERE asset_event_type_id=#{AssetEventType.find_by(class_name: 'PerformanceRestrictionUpdateEvent').id} GROUP BY base_transam_asset_id ) AS restriction_counts ON restriction_counts.base_transam_asset_id = transam_assets.id")
                .joins('LEFT JOIN performance_restriction_types ON performance_restriction_types.id = restriction_event.performance_restriction_type_id')
                .joins('INNER JOIN assets_fta_mode_types ON assets_fta_mode_types.transam_asset_type = "Infrastructure" AND assets_fta_mode_types.transam_asset_id = infrastructures.id AND assets_fta_mode_types.is_primary=1')
                .joins('INNER JOIN fta_mode_types ON assets_fta_mode_types.fta_mode_type_id = fta_mode_types.id')
                .where(organization_id: organization_id_list)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent', fta_type: FtaTrackType.where(name: ['Non-Revenue Service', 'Revenue Track - No Capital Replacement Responsibility'])})

    if TamPolicy.first
      asset_levels = fta_asset_category.asset_levels
      policy = TamPolicy.first.tam_performance_metrics.includes(:tam_group).where(tam_groups: {state: ['pending_activation','activated']}).where(asset_level: asset_levels).select('tam_groups.organization_id', 'asset_level_id', 'pcnt_goal', 'tam_groups.state')

      query = query.joins("LEFT JOIN (#{policy.to_sql}) as ulbs ON ulbs.organization_id = transam_assets.organization_id AND ulbs.asset_level_id = transit_assets.fta_type_id AND fta_type_type = '#{asset_levels.first.class.name}'")
    end

    cols = ['organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name', 'fta_track_types.name', 'asset_subtypes.name', 'CONCAT(fta_mode_types.code," - " ,fta_mode_types.name)','infrastructures.from_line', 'infrastructures.from_segment', 'infrastructures.to_line', 'infrastructures.to_segment', 'infrastructures.segment_unit', 'infrastructures.from_location_name', 'infrastructures.to_location_name', 'transam_assets.description', 'transam_assets.asset_tag', 'transam_assets.external_id',  'infrastructure_segment_types.name', 'infrastructure_divisions.name', 'infrastructure_subdivisions.name', 'infrastructure_tracks.name', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")', 'infrastructures.max_permissible_speed', 'infrastructures.max_permissible_speed_unit', 'IF(restriction_counts.count_all> 0, "YES","NO")','IF(restriction_counts.count_all> 1, "Multiple",performance_restriction_types.name)',"'#{TamPolicy.first.fy_year}'","IFNULL(pcnt_goal,'')",'YEAR(CURDATE()) - YEAR(in_service_date)','rating_event.assessed_rating']

    labels = ['Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype', 'Mode', 'Line','From', 'Line',	'To',	'Unit',	'From (location name)',	'To (location name)',	'Description / Segment Name',	'Asset / Segment ID',	'External ID',	'Segment Type',	'Main Line / Division',	'Branch / Subdivision',	'Track',	'In Service Date',	'Purchase Date',	'Purchase Cost',	'Purchased New',	'Rehabbed Asset?',	'Direct Capital Responsibility', 	'Maximum Permissible Speed',	'Unit',	'Active Performance Restriction', 'Restriction Cause',	'TAM Policy Year','Goal Pcnt','Age',	'Current Condition (TERM)']

    formats = [:string, :string, :string, :string, :string, :string, :string, :decimal, :string, :decimal, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :integer, :string, :integer, :string, :string, :string, :string, :decimal, :string, :decimal, :string, :string, :integer, :fiscal_year, :percent, :integer, :decimal]

    data = query.pluck(*cols)
    
    return {labels: labels, data: data, formats: formats}
  end

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)

    data = []

    single_org_view = params[:has_organization].to_i == 1 || organization_id_list.count == 1

    query = Track.operational.joins(transit_asset: [{transam_asset: :organization}, :fta_asset_class])
                .joins('INNER JOIN assets_fta_mode_types ON assets_fta_mode_types.transam_asset_type = "Infrastructure" AND assets_fta_mode_types.transam_asset_id = infrastructures.id AND assets_fta_mode_types.is_primary=1')
                .joins('INNER JOIN fta_mode_types ON assets_fta_mode_types.fta_mode_type_id = fta_mode_types.id')
                .where(organization_id: organization_id_list)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent', fta_type: FtaTrackType.where(name: ['Non-Revenue Service', 'Revenue Track - No Capital Replacement Responsibility'])})

    tam_data = grouped_activated_tam_performance_metrics(organization_id_list, fta_asset_category, single_org_view, query.group('organizations.short_name', 'CONCAT(fta_mode_types.code," - " ,fta_mode_types.name)').count)

    if single_org_view
      grouped_query = query.group('organizations.short_name')
    else
      grouped_query = query
    end
    grouped_query = grouped_query.group('CONCAT(fta_mode_types.code," - " ,fta_mode_types.name)')

    assets_count = grouped_query.distinct.count('transam_assets.id')

    weather_performance_restriction = PerformanceRestrictionType.find_by(name: 'Weather')
    line_lengths = Hash.new
    restriction_lengths = Hash.new
    assets_count.keys.each do |mode|
      total_restriction_segment = 0
      total_asset_segment = 0
      query.where(fta_mode_types: {code: (single_org_view ? mode.last : mode).split('-')[0].strip}).get_lines.each do |line|
        total_restriction_segment += PerformanceRestrictionUpdateEvent.where(transam_asset: line).where.not(performance_restriction_type: weather_performance_restriction, state: 'expired').total_segment_length
        total_asset_segment += line.total_segment_length
      end

      line_lengths[mode] = total_asset_segment
      restriction_lengths[mode] = total_restriction_segment
    end

    total_age = grouped_query.sum('YEAR(CURDATE()) - YEAR(in_service_date)')

    assets_count.each do |k, v|
      assets = query.where(fta_mode_types: {name: (single_org_view ? k.last : k).split('-').last.strip}, organization_id: organization_id_list).where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent', fta_type: FtaTrackType.where(name: ['Non-Revenue Service', 'Revenue Track - No Capital Replacement Responsibility'])})

      condition_events = ConditionUpdateEvent
                        .where(id: AssetEvent
                                .where(base_transam_asset_id: assets.select('transam_assets.id'),
                                       asset_event_type_id: AssetEventType
                                         .find_by(class_name: 'ConditionUpdateEvent'))
                                .group(:base_transam_asset_id).maximum(:id).values)
      condition_events_count = condition_events.count

      row = (single_org_view ? [] : ['All (Filtered) Organizations']) + [*k, line_lengths[k], TamPolicy.first.try(:fy_year), (tam_data[k] || [])[1], restriction_lengths[k], v > 0 ? (restriction_lengths[k]*100.0/line_lengths[k] + 0.5).to_i : 0, (total_age[k]/v.to_f).round(1), condition_events_count > 0 ? condition_events.sum(:assessed_rating)/condition_events_count.to_f : condition_events_count ]
      data << row
    end

    return {labels: COMMON_LABELS, data: data, formats: COMMON_FORMATS}
  end

  def fta_asset_category
    @fta_asset_category ||= FtaAssetCategory.find_by(name: 'Infrastructure')
  end

end