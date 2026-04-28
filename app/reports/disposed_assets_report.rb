class DisposedAssetReport < AbstractReport
  include FiscalYear

  def get_actions
    @actions = [
      {
        type: :select,
        where: :start_disposition_year,
        values: (current_fiscal_year_year - SystemConfig.instance.num_forecasting_years..current_fiscal_year_year).to_a,
        label: "From"
      },
      {
        type: :select,
        where: :end_disposition_year,
        values: (current_fiscal_year_year - SystemConfig.instance.num_forecasting_years..current_fiscal_year_year).to_a,
        label: "To"
      },
      {
        type: :text_field,
        where: :proceeds_at_least,
        value: 10000,
        label: "Proceeds At Least $"
      },
      {
        type: :select,
        where: :asset_class,
        values: FtaAssetClass.active.pluck(:name, :id),
        label: "Class"
      },
      {
        type: :select,
        where: :asset_type,
        values: [nil, nil],
        label: "Type"
      },
      {
        type: :check_box_collection,
        group: :federally_funded,
        values: [:federally_funded_only]
      }
    ]
  end

  # TODO: implement for this report
  def get_data(organization_id_list, params)

    labels = ["Disposition Year", "Flag", "Organization", "Asset Count", "Total Proceeds"]
    formats = [:hidden, :boolean, :string, :integer, :currency]

    # Order by disposition date, then by org
    # query = TransamAsset.select("CASE WHEN (MONTH(transam_assets.disposition_date) > #{SystemConfig.instance.start_of_fiscal_year.split("-")[0]}) THEN (YEAR(transam_assets.disposition_date)) ELSE (CASE WHEN (MONTH(transam_assets.disposition_date) = #{SystemConfig.instance.start_of_fiscal_year.split("-")[0]} AND DAY(transam_assets.disposition_date) >= #{SystemConfig.instance.start_of_fiscal_year.split("-")[1]}) THEN (YEAR(transam_assets.disposition_date)) ELSE (YEAR(transam_assets.disposition_date) - 1) END) END AS disposition_year, organizations.name AS org_name, sales_proceeds")
    #                     .joins(:organization)
    #                     .joins('LEFT JOIN asset_events ON asset_events.base_transam_asset_id = transam_assets.id AND asset_events.event_date = transam_assets.disposition_date')
    #                     .joins('LEFT JOIN grant_purchases ON grant_purchases.transam_asset_id = transam_assets.id')
    #                     .joins('LEFT JOIN funding_sources ON grant_purchases.sourceable_id = funding_sources.id')
    #                     .joins('LEFT JOIN funding_source_types ON funding_source_types.id = funding_sources.funding_source_type_id')
    #                     .joins('LEFT JOIN transit_assets ON transit_assets.id = transam_assets.transam_assetible_id')
    #                     .joins('LEFT JOIN fta_asset_classes ON fta_asset_classes.id = transit_assets.fta_asset_class_id')
    #                     .where.not(transam_assets: {disposition_date: nil}, asset_events: {sales_proceeds: nil})
    #                     .order('disposition_year', 'org_name')

    # Set up base of query, selecting only columns needed for aggregate data, and sorting by fiscal year disposed
    # TODO: couldn't get group by to work as intended for aggregate functions, so will need to iterate through objects for now
    select_columns = [
      "CASE WHEN (MONTH(transam_assets.disposition_date) > #{SystemConfig.instance.start_of_fiscal_year.split("-")[0]}) THEN (YEAR(transam_assets.disposition_date)) ELSE (CASE WHEN (MONTH(transam_assets.disposition_date) = #{SystemConfig.instance.start_of_fiscal_year.split("-")[0]} AND DAY(transam_assets.disposition_date) >= #{SystemConfig.instance.start_of_fiscal_year.split("-")[1]}) THEN (YEAR(transam_assets.disposition_date)) ELSE (YEAR(transam_assets.disposition_date) - 1) END) END AS disposition_year",
      "organizations.name AS org_name",
      "asset_events.sales_proceeds"
    ]
    join_tables = [
      "organizations ON organizations.id = transam_assets.organization_id",
      "asset_events ON asset_events.base_transam_asset_id = transam_assets.id AND asset_events.event_date = transam_assets.disposition_date",
      "grant_purchases ON grant_purchases.transam_asset_id = transam_assets.id",
      "funding_sources ON grant_purchases.sourceable_id = funding_sources.id",
      "funding_source_types ON funding_source_types.id = funding_sources.funding_source_type_id",
      "transit_assets ON transit_assets.id = transam_assets.transam_assetible_id",
      "fta_asset_classes ON fta_asset_classes.id = transit_assets.fta_asset_class_id"
    ]

    # Add clauses based on params
    conditions = [
      "transam_assets.organization_id IN (#{organization_id_list.join(",")})",
      "transam_assets.disposition_date IS NOT null",
      "asset_events.sales_proceeds IS NOT null"
    ]

    value = params[:start_disposition_year] || current_fiscal_year_year - 1
    start_year = start_of_fiscal_year(value)
    conditions << "transam_assets.disposition_date >= '#{start_year}'"

    value = params[:end_disposition_year] || current_fiscal_year_year
    end_year = end_of_fiscal_year(value)
    conditions << "transam_assets.disposition_date <= '#{end_year}'"

    value = params[:proceeds_at_least] || 0
    sales_proceeds = value.to_i
    conditions << "asset_events.sales_proceeds >= #{sales_proceeds}"

    value = params[:asset_class] || FtaAssetClass.active.first.id
    conditions << "transit_assets.fta_asset_class_id = #{value.to_i}"

    # add appropriate fta type table for the selected class in order to fill in asset details
    fta_type_mappings = {
      "RevenueVehicle" => "vehicle",
      "ServiceVehicle" => "support_vehicle",
      "CapitalEquipment" => "equipment",
      "Facility" => "facility",
      "Guideway" => "guideway",
      "PowerSignal" => "power_signal",
      "Track" => "track"
    }
    fta_type_table = fta_type_mappings[FtaAssetClass.find(value.to_i).class_name]
    join_tables << "fta_#{fta_type_table}_types ON fta_#{fta_type_table}_types.id = transit_assets.fta_type_id AND transit_assets.fta_type_type = 'Fta#{fta_type_table.camelize}Type'"

    if params[:asset_type] && params[:asset_type] != ""
      value = params[:asset_type]
      conditions << "transit_assets.fta_type_id = #{value.to_i}"
    end

    if params[:federally_funded] && params[:federally_funded] != ""
      conditions << 'funding_source_types.name = "Federal"' if params[:federally_funded] == :federally_funded_only
    end

    # Validation
    if end_year < start_year
      return "To Year cannot be before From Year."
    end

    query_string = "SELECT " + select_columns.join(", ") + " FROM transam_assets LEFT JOIN " + join_tables.join(" LEFT JOIN ") + " WHERE " + conditions.join(" AND ") + " GROUP BY transam_assets.id ORDER BY disposition_year DESC, org_name ASC;"

    query = TransamAsset.find_by_sql(query_string)

    data = []
    year_data = []
    current_year = nil
    current_org = nil
    asset_count = total_proceeds = 0
    flag_present = false

    query.each do |da|
      if current_year != da.disposition_year
        if current_year
          year_data << [current_year, flag_present, current_org, asset_count, total_proceeds]
          data << [current_year, year_data]
        end
        current_org = da.org_name
        asset_count = 1
        total_proceeds = da.sales_proceeds
        flag_present = da.sales_proceeds >= 10000
        year_data = []
        current_year = da.disposition_year
      else
        if current_org == da.org_name
          asset_count += 1
          total_proceeds += da.sales_proceeds
          flag_present ||= da.sales_proceeds >= 10000
        else
          if current_org
            year_data << [current_year, flag_present, current_org, asset_count, total_proceeds]
          end
          current_org = da.org_name
          asset_count = 1
          total_proceeds = da.sales_proceeds
          flag_present = da.sales_proceeds >= 10000
        end
      end
    end
    if current_year
      year_data << [current_year, flag_present, current_org, asset_count, total_proceeds]
      data << [current_year, year_data]
    else
      # Handle the case when no Draft Project are found with the given parameters.
      labels = []
      # Pass a warning message where the organization name would normally go.
      data << ["No disposed assets found using the selected filters.", []]
    end
    return {labels: labels, data: data, formats: formats}
  end

  def self.get_detail_data(year, organization_id, params)
    labels = ['Flag', 'Asset ID', 'Asset Class', 'Asset Type', 'Asset Subtype', 'Federally Funded', 'Disposition Date', 'Disposition Type', 'Disposition Proceeds', 'Mileage', 'Condition', 'Age']
    formats = [:boolean, :string, :string, :string, :string, :boolean, :date, :string, :currency, :integer, :string, :integer]

    query = TransitAsset.joins(:transam_asset)
                        .joins('LEFT JOIN organizations ON organizations.id = transam_assets.organization_id')
                        .joins('LEFT JOIN asset_events ON asset_events.base_transam_asset_id = transam_assets.id AND asset_events.event_date = transam_assets.disposition_date')
                        .joins('LEFT JOIN grant_purchases ON grant_purchases.transam_asset_id = transam_assets.id')
                        .joins('LEFT JOIN funding_sources ON grant_purchases.sourceable_id = funding_sources.id')
                        .joins('LEFT JOIN funding_source_types ON funding_source_types.id = funding_sources.funding_source_type_id')
                        .joins('LEFT JOIN fta_asset_classes ON fta_asset_classes.id = transit_assets.fta_asset_class_id')
                        .where(transam_assets: {organization_id: organization_id, disposition_date: start_of_fiscal_year(year)..end_of_fiscal_year(year)})
                        .where.not(transam_assets: {disposition_date: nil}, asset_events: {sales_proceeds: nil})
                        .order('transam_assets.disposition_date DESC').uniq

    conditions = []

    value = params[:proceeds_at_least] || 0
    sales_proceeds = value.to_i
    conditions << "asset_events.sales_proceeds >= #{sales_proceeds}"

    value = params[:asset_class] || FtaAssetClass.active.first.id
    conditions << "transit_assets.fta_asset_class_id = #{value.to_i}"

    # add appropriate fta type table for the selected class in order to fill in asset details
    fta_type_mappings = {
      "RevenueVehicle" => "vehicle",
      "ServiceVehicle" => "support_vehicle",
      "CapitalEquipment" => "equipment",
      "Facility" => "facility",
      "Guideway" => "guideway",
      "PowerSignal" => "power_signal",
      "Track" => "track"
    }
    fta_type_table = fta_type_mappings[FtaAssetClass.find(value.to_i).class_name]
    query = query.joins("LEFT JOIN fta_#{fta_type_table}_types ON fta_#{fta_type_table}_types.id = transit_assets.fta_type_id AND transit_assets.fta_type_type = 'Fta#{fta_type_table.camelize}Type'")

    if params[:asset_type] && params[:asset_type] != ""
      value = params[:asset_type]
      conditions << "transit_assets.fta_type_id = #{value.to_i}"
    end

    if params[:federally_funded] && params[:federally_funded] != ""
      conditions << 'funding_source_types.name = "Federal"' if params[:federally_funded] == :federally_funded_only
    end

    data = []
    query = query.where(conditions.join(" AND "))

    query.each do |asset|
      latest_disposition_event = DispositionUpdateEvent.find(asset.asset_events.where(asset_event_type: AssetEventType.find_by(class_name: "DispositionUpdateEvent")).order(:event_date, :created_at).last.id)
      row = [
        latest_disposition_event.sales_proceeds >= 10000,
        asset.asset_tag,
        asset.fta_asset_class_name,
        asset.fta_type.to_s,
        asset.asset_subtype.name,
        asset.funding_sources.where(name: "Federal").count > 0,
        asset.disposition_date,
        latest_disposition_event.disposition_type.name,
        latest_disposition_event.sales_proceeds,
        latest_disposition_event,mileage_at_disposition,
        asset.reported_condition_rating,
        latest_disposition_event.age_at_disposition
      ]
      data << row
    end

    {labels: labels, data: data, formats: formats}
  end
end