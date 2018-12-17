class InfrastructureTamPolicyServiceLifeReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Organization', 'Primary Mode', 'Line Length','Active Performance Restrictions', 'Pcnt', 'Avg Age', 'Avg TERM Condition']
  COMMON_FORMATS = [:string, :string, :decimal, :decimal, :percent, :decimal, :decimal]

  def self.get_underlying_data(organization_id_list, params)

    query = Track.operational.joins(:infrastructure_segment_type, :infrastructure_division, :infrastructure_subdivision, :infrastructure_track)
                .joins('INNER JOIN organizations ON transam_assets.organization_id = organizations.id')
                .joins('INNER JOIN asset_subtypes ON transam_assets.asset_subtype_id = asset_subtypes.id')
                .joins('INNER JOIN fta_asset_categories ON transit_assets.fta_asset_category_id = fta_asset_categories.id')
                .joins('INNER JOIN fta_asset_classes ON transit_assets.fta_asset_class_id = fta_asset_classes.id')
                .joins('INNER JOIN fta_track_types ON transit_assets.fta_type_id = fta_track_types.id AND transit_assets.fta_type_type = "FtaTrackType"')
                .joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id')
                .joins('LEFT JOIN recent_asset_events_views AS recent_rating ON recent_rating.base_transam_asset_id = transam_assets.id AND recent_rating.asset_event_name = "Condition"')
                .joins('LEFT JOIN asset_events AS rating_event ON rating_event.id = recent_rating.asset_event_id')
                .joins('LEFT JOIN recent_asset_events_views AS performance_restriction ON performance_restriction.base_transam_asset_id = transam_assets.id AND performance_restriction.asset_event_name = "Performance Restrictions"')
                .joins('LEFT JOIN asset_events AS restriction_event ON restriction_event.id = performance_restriction.asset_event_id')
                .joins("LEFT JOIN (SELECT base_transam_asset_id, COUNT(*) as count_all FROM asset_events WHERE asset_event_type_id=#{AssetEventType.find_by(class_name: 'PerformanceRestrictionUpdateEvent').id} GROUP BY base_transam_asset_id ) AS restriction_counts ON restriction_counts.base_transam_asset_id = transam_assets.id")
                .joins('LEFT JOIN performance_restriction_types ON performance_restriction_types.id = restriction_event.performance_restriction_type_id')
                .where(organization_id: organization_id_list)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'Component', fta_type: FtaTrackType.find_by(name: 'Non-Revenue Service')}, restriction_event: {performance_restriction_type_id: PerformanceRestrictionType.find_by(name: 'Weather').id, state: 'expired'})

    cols = ['organizations.short_name', 'fta_asset_categories.name', 'fta_asset_classes.name', 'fta_track_types.name', 'asset_subtypes.name', 'infrastructures.from_line', 'infrastructures.from_segment', 'infrastructures.to_line', 'infrastructures.to_segment', 'infrastructures.segment_unit', 'infrastructures.from_location_name', 'infrastructures.to_location_name', 'transam_assets.description', 'transam_assets.asset_tag', 'transam_assets.external_id',  'infrastructure_segment_types.name', 'infrastructure_divisions.name', 'infrastructure_subdivisions.name', 'infrastructure_tracks.name', 'transam_assets.in_service_date', 'transam_assets.purchase_date', 'transam_assets.purchase_cost', 'IF(transam_assets.purchased_new, "YES", "NO")', 'IF(IFNULL(sum_extended_eul, 0)>0, "YES", "NO")', 'IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO")', 'infrastructures.max_permissible_speed', 'infrastructures.max_permissible_speed_unit', 'IF(restriction_counts.count_all> 0, "YES","NO")','IF(restriction_counts.count_all> 1, "Multiple",performance_restriction_types.name)','YEAR(CURDATE()) - YEAR(in_service_date)','rating_event.assessed_rating']

    labels = ['Agency','Asset Category', 'Asset Class', 'Asset Type','Asset Subtype', 'Line','From', 'Line',	'To',	'Unit',	'From (location name)',	'To (location name)',	'Description / Segment Name',	'Asset / Segment ID',	'External ID',	'Segment Type',	'Main Line / Division',	'Branch / Subdivision',	'Track',	'In Service Date',	'Purchase Date',	'Purchase Cost',	'Purchased New',	'Rehabbed Asset?',	'Direct Capital Responsibility', 	'Maximum Permissible Speed',	'Unit',	'Active Performance Restriction', 'Restriction Cause',	'Age',	'Current Condition (TERM)']

    formats = [:string, :string, :string, :string, :string, :string, :decimal, :string, :decimal, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :date, :date, :currency, :string, :string, :string, :integer, :string, :integer, :string, :string, :string, :string, :decimal, :string, :decimal, :string, :string, :integer, :integer, :decimal]

    data = query.pluck(*cols)
    
    return {labels: labels, data: data, formats: formats}
  end

  def self.get_detail_data(organization_id_list, params)
    key = params[:key]
    key = key[5..-1].strip if key.index(' - ') == 2

    data = []

    unless key.blank?
      query = Track.operational.joins(transit_asset: [{transam_asset: :organization}, :fta_asset_class])
                  .joins('INNER JOIN assets_fta_mode_types ON assets_fta_mode_types.transam_asset_type = "Infrastructure" AND assets_fta_mode_types.transam_asset_id = infrastructures.id AND assets_fta_mode_types.is_primary=1')
                  .joins('INNER JOIN fta_mode_types ON assets_fta_mode_types.fta_mode_type_id = fta_mode_types.id')
                  .joins('LEFT JOIN recent_asset_events_views AS performance_restriction ON performance_restriction.base_transam_asset_id = transam_assets.id AND performance_restriction.asset_event_name = "Performance Restrictions"')
                  .joins('LEFT JOIN asset_events AS restriction_event ON restriction_event.id = performance_restriction.asset_event_id')
                  .where(organization_id: organization_id_list)
                  .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'Component', fta_type: FtaTrackType.find_by(name: 'Non-Revenue Service')}, restriction_event: {performance_restriction_type_id: PerformanceRestrictionType.find_by(name: 'Weather').id, state: 'expired'})
                  .where(fta_mode_types: {name: key})

      grouped_query = query.group('organizations.short_name').group('CONCAT(fta_mode_types.code," - " ,fta_mode_types.name)')

      assets_count = grouped_query.distinct.count('transam_assets.id')

      min_from_segments = query.group(:infrastructure_track_id, :from_line, :to_line).minimum(:from_segment)
      maximum_to_segments = query.where.not(to_segment: nil).group(:organization_id, :infrastructure_track_id, :from_line, :to_line).maximum(:to_segment)

      line_lengths = 0
      maximum_to_segments.each do |key, to_seg|
        line_lengths += (to_seg - min_from_segments[key])
      end

      restriction_lengths = grouped_query.distinct.sum('restriction_event.to_segment - restriction_event.from_segment')

      total_age = grouped_query.sum('YEAR(CURDATE()) - YEAR(in_service_date)')

      line_lengths.each do |k, v|
        assets = query.where(fta_mode_types: {name: key}, organization_id: organization_id_list)
        #total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'TransamAsset', base_transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)
        total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(base_transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)

        row = [ *k, v, restriction_lengths[k], (restriction_lengths[k]*100.0/v + 0.5).to_i, (total_age[k]/assets_count[k].to_f).round(1), total_condition/assets_count[k].to_f ]
        data << row
      end
    end

    return {labels: COMMON_LABELS, data: data, formats: COMMON_FORMATS}

  end

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)

    data = []

    query = Track.operational.joins(transit_asset: [{transam_asset: :organization}, :fta_asset_class])
                .joins('INNER JOIN assets_fta_mode_types ON assets_fta_mode_types.transam_asset_type = "Infrastructure" AND assets_fta_mode_types.transam_asset_id = infrastructures.id AND assets_fta_mode_types.is_primary=1')
                .joins('INNER JOIN fta_mode_types ON assets_fta_mode_types.fta_mode_type_id = fta_mode_types.id')
                .joins('LEFT JOIN recent_asset_events_views AS performance_restriction ON performance_restriction.base_transam_asset_id = transam_assets.id AND performance_restriction.asset_event_name = "Performance Restrictions"')
                .joins('LEFT JOIN asset_events AS restriction_event ON restriction_event.id = performance_restriction.asset_event_id')
                .where(organization_id: organization_id_list)
                .where.not(transit_assets: {pcnt_capital_responsibility: nil, transit_assetible_type: 'Component', fta_type: FtaTrackType.find_by(name: 'Non-Revenue Service')}, restriction_event: {performance_restriction_type_id: PerformanceRestrictionType.find_by(name: 'Weather').id, state: 'expired'})

    grouped_query = query.group('CONCAT(fta_mode_types.code," - " ,fta_mode_types.name)')

    assets_count = grouped_query.distinct.count('transam_assets.id')

    min_from_segments = query.group(:infrastructure_track_id, :from_line, :to_line).minimum(:from_segment)
    maximum_to_segments = query.where.not(to_segment: nil).group(:organization_id, :infrastructure_track_id, :from_line, :to_line).maximum(:to_segment)

    line_lengths = 0
    maximum_to_segments.each do |key, to_seg|
      line_lengths += (to_seg - min_from_segments[key])
    end

    restriction_lengths = grouped_query.distinct.sum('restriction_event.to_segment - restriction_event.from_segment')

    total_age = grouped_query.sum('YEAR(CURDATE()) - YEAR(in_service_date)')

    org_label = organization_id_list.count > 1 ? 'All (Filtered) Organizations' : Organization.where(id: organization_id_list).first.short_name

    line_lengths.each do |k, v|
      assets = query.where(fta_mode_types: {name: k.split('-').last.strip}, organization_id: organization_id_list)
      #total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(transam_asset_type: 'TransamAsset', base_transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)
      total_condition = ConditionUpdateEvent.where(id: RecentAssetEventsView.where(base_transam_asset_id: assets.select('transam_assets.id'), asset_event_name: 'Condition').select(:asset_event_id)).sum(:assessed_rating)

      row = [ org_label,*k, v, restriction_lengths[k], v > 0 ? (restriction_lengths[k]*100.0/v + 0.5).to_i : 0, (total_age[k]/assets_count[k].to_f).round(1), total_condition/assets_count[k].to_f ]
      data << row
    end

    return {labels: COMMON_LABELS, data: data, formats: COMMON_FORMATS}
  end

end