#-------------------------------------------------------------------------------
#
# CapitalProjectBuilder
#
# Analyzes an organizations's assets and generates a set of capital projects
# for the organization.
#
#-------------------------------------------------------------------------------
class AssetFleetBuilder
  attr_accessor :asset_fleet_type
  attr_accessor :organization
  attr_accessor :query


  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  def group_by_fields(fleet_type)
    group_by_fields = fleet_type.standard_group_by_fields + ['primary_modes.fta_mode_type_id as primary_fta_mode_type_id']

    if fleet_type.class_name == 'ServiceVehicle'
      group_by_fields << ['secondary_modes.fta_mode_types_str as secondary_fta_mode_types']
    else
      group_by_fields << ['secondary_modes.fta_mode_type_id as secondary_fta_mode_type_id','IF(transit_assets.pcnt_capital_responsibility > 0, "YES", "NO") as direct_capital_responsibility', 'service_types.fta_service_type_id as primary_fta_service_type_id', 'secondary_service_types.fta_service_type_id as secondary_fta_service_type_id']
    end

    group_by_fields.flatten
  end

  def asset_query(fleet_type, organization)

    query = fleet_type.class_name.constantize
                .where(organization_id: organization.id)
                .where(TransamAsset.arel_table[:asset_tag].not_eq(TransamAsset.arel_table[:object_key]))
                .joins('LEFT JOIN (SELECT * FROM assets_fta_mode_types WHERE is_primary=1) AS primary_modes ON service_vehicles.id = primary_modes.transam_asset_id')


    if fleet_type.class_name == 'ServiceVehicle'
      query = query
                  .joins('LEFT JOIN (SELECT transam_asset_id, GROUP_CONCAT(code SEPARATOR " ") as fta_mode_types_str FROM assets_fta_mode_types INNER JOIN fta_mode_types ON assets_fta_mode_types.fta_mode_type_id = fta_mode_types.id WHERE is_primary IS NULL OR is_primary !=1 GROUP BY transam_asset_id) AS secondary_modes ON service_vehicles.id = secondary_modes.transam_asset_id')
    else
      query = query
                  .joins('LEFT JOIN (SELECT * FROM assets_fta_mode_types WHERE is_primary IS NULL OR is_primary!=1) AS secondary_modes ON service_vehicles.id = secondary_modes.transam_asset_id')
                  .joins('LEFT JOIN (SELECT * FROM assets_fta_service_types WHERE is_primary=1) AS service_types ON revenue_vehicles.id = service_types.transam_asset_id')
                  .joins('LEFT JOIN (SELECT * FROM assets_fta_service_types WHERE is_primary IS NULL OR is_primary!=1) AS secondary_service_types ON revenue_vehicles.id = secondary_service_types.transam_asset_id')
    end

    query
  end

  def asset_group_values(options={})
    query_values = @query.joins('LEFT JOIN assets_asset_fleets ON service_vehicles.id = assets_asset_fleets.transam_asset_id')


    # trying to get the group values if given an asset or fleet
    # if not given anything look only at assets not in fleets already and return an array of arrays of all possible grouped values
    if options[:asset]
      query_values = query_values.where(transam_assets: {object_key: options[:asset].object_key})
    elsif options[:fleet]
      query_values = query_values.where(transam_assets: {object_key: options[:fleet].active_assets.first.object_key})
    else
      query_values = query_values.where('assets_asset_fleets.transam_asset_id IS NULL')
    end

    query_values = query_values.group(*@asset_fleet_type.group_by_fields).pluck(*group_by_fields(@asset_fleet_type))

    if options[:asset] || options[:fleet]
      query_values.first
    else
      query_values
    end
  end

  def available_fleets(asset_group_value)

    conditions = []
    @asset_fleet_type.group_by_fields.each_with_index do |field, idx|
      if asset_group_value[idx].present?
        conditions << "#{field} = ?"
      else
        conditions << "(#{field} IS NULL OR #{field} = '')"
      end
    end

    possible_assets = @query
                          .having(conditions.join(' AND '), *(asset_group_value.select{|x| x.present?}))
                          .pluck(*group_by_fields(@asset_fleet_type), 'object_key').map{|x| x[-1]}

    AssetFleet.distinct.joins(:assets).where(transam_assets: {object_key: possible_assets})
  end

  def available_assets(asset_group_value)

    conditions = []
    @asset_fleet_type.group_by_fields.each_with_index do |field, idx|
      if asset_group_value[idx].present?
        conditions << "#{field} = ?"
      else
        conditions << "(#{field} IS NULL OR #{field} = '')"
      end
    end

    assets = ServiceVehicle.where(object_key: @query
                    .joins('LEFT JOIN assets_asset_fleets ON service_vehicles.id = assets_asset_fleets.transam_asset_id')
                   .where('assets_asset_fleets.transam_asset_id IS NULL')
                   .having(conditions.join(' AND '), *(asset_group_value.select{|x| x.present?}))
                   .pluck(*group_by_fields(@asset_fleet_type), 'object_key').map{|x| x[-1]})

    assets
  end

  # Main entry point for the builder. This invokes the bottom-up builder
  def build(options={})

    sys_user = User.find_by(first_name: 'system')

    if options[:action].to_i == FleetBuilderProxy::RESET_ALL_ACTION
      reset_all
    end

    group_by_values = asset_group_values

    group_by_values.each do |vals|

      unless options[:action].to_i == FleetBuilderProxy::USE_EXISTING_FLEET_ACTION
        fleet = AssetFleet.new
        fleet.organization_id = organization.id
        fleet.asset_fleet_type = @asset_fleet_type
        fleet.creator = sys_user
        fleet.save!
      else
        fleet = available_fleets(vals).first
      end

      fleet.assets << available_assets(vals)

    end

  end

  def reset_all
    AssetFleet.where(organization: @organization, asset_fleet_type: @asset_fleet_type).destroy_all
  end

  # Set resonable defaults for the builder
  def initialize(fleet_type, organization)
    self.organization = organization
    self.asset_fleet_type = fleet_type

    self.query = asset_query(fleet_type, organization)
  end

  #-----------------------------------------------------------------------------
  #
  # Private Methods
  #
  #-----------------------------------------------------------------------------
  private

end

