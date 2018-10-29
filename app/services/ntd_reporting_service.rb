#------------------------------------------------------------------------------
#
# NTD Reporting Service
#
# Manages business logic for generating NTD reports for an organization
#
#
#------------------------------------------------------------------------------
class NtdReportingService

  include FiscalYear

  def initialize(params)
    @report = params[:report]
    @process_log = ProcessLog.new

    if Rails.application.config.asset_base_class_name == 'TransamAsset'
      @types = {revenue_vehicle_fleets: 'RevenueVehicle', service_vehicle_fleets: 'ServiceVehicle', facilities: 'Facility'}
    else
      @types = {revenue_vehicle_fleets: 'Vehicle', service_vehicle_fleets: 'SupportVehicle', facilities: 'FtaBuilding'}
    end

  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def process_log
    @process_log.to_s
  end

  # Returns a collection of revenue vehicle fleets by grouping vehicle assets in
  # for the organization on the NTD fleet groups and calculating the totals for
  # the columns which need it
  def revenue_vehicle_fleets(orgs)

    fleets = []

    AssetFleet.where(organization: orgs, asset_fleet_type: AssetFleetType.find_by(class_name: @types[:revenue_vehicle_fleets])).each do |row|
      next if row.assets.empty?
      
      primary_mode = check_seed_field(row, 'primary_fta_mode_type')
      primary_tos = check_seed_field(row, 'primary_fta_service_type')
      vehicle_type = check_seed_field(row, 'fta_type')
      funding_type = check_seed_field(row, 'fta_funding_type')
      ownership_type = check_seed_field(row, 'fta_ownership_type')
      manufacturer_model = row.get_manufacturer_model
      
      fleet ={
          rvi_id: row.ntd_id,
          fta_mode: primary_mode.try(:code),
          fta_service_type: primary_tos.try(:code),
          agency_fleet_id: row.agency_fleet_id,
          dedicated: row.get_dedicated,
          direct_capital_responsibility: row.get_direct_capital_responsibility,
          size: row.total_count,
          num_active: row.active_count,
          num_ada_accessible: row.ada_accessible_count,
          num_emergency_contingency: row.fta_emergency_contingency_count,
          vehicle_type: vehicle_type ? "#{vehicle_type.name} (#{vehicle_type.code})" : nil,
          manufacture_code: row.get_manufacturer.try(:to_s),
          rebuilt_year: '',
          model_number: manufacturer_model ? (manufacturer_model.name == 'Other' ? row.get_other_manufacturer_model : manufacturer_model) : nil,
          other_manufacturer: row.get_other_manufacturer.try(:to_s),
          fuel_type: row.get_fuel_type.try(:name),
          other_fuel_type: row.get_other_fuel_type,
          dual_fuel_type: row.get_dual_fuel_type.try(:to_s),
          vehicle_length: row.get_vehicle_length,
          seating_capacity: row.get_seating_capacity,
          standing_capacity: row.get_standing_capacity,
          total_active_miles_in_period: row.miles_this_year(end_of_fiscal_year(@report.ntd_form.fy_year)),
          avg_lifetime_active_miles: row.avg_active_lifetime_miles,
          ownership_type: ownership_type ? "#{ownership_type.name} (#{ownership_type.code})" : nil,
          other_ownership_type: row.get_other_fta_ownership_type,
          funding_type: funding_type ? "#{funding_type.name} (#{funding_type.code})" : nil,
          notes: row.notes,
          status: row.active(@report.ntd_form.fy_year) ? 'Active' : 'Retired',
          useful_life_remaining: row.useful_life_remaining,
          useful_life_benchmark: row.useful_life_benchmark,
          manufacture_year: row.get_manufacture_year,
          additional_fta_mode: row.get_secondary_fta_mode_type.try(:code),
          additional_fta_service_type: row.get_secondary_fta_service_type.try(:code),
          vehicle_object_key: row.object_key
      }

      # calculate the additional properties and merge them into the results
      # hash
      fleets << NtdRevenueVehicleFleet.new(fleet)
    end
    fleets

  end

  # Returns a collection of service vehicle fleets by grouping vehicle assets in
  # the organizations on the NTD fleet groups and calculating the totals for
  # the columns which need it the grouping in this case will be the same as revenue
  # because the current document has no guidelines for groupind service vehicles.
  def service_vehicle_fleets(orgs)

    fleets = []

    AssetFleet.where(organization: orgs, asset_fleet_type: AssetFleetType.find_by(class_name: @types[:service_vehicle_fleets])).each do |row|

      primary_mode = check_seed_field(row, 'primary_fta_mode_type')
      vehicle_type = check_seed_field(row, 'fta_type')

      service_fleet = {
          :sv_id => row.ntd_id,
          :agency_fleet_id => row.agency_fleet_id,
          :fleet_name => row.fleet_name,
          :size => row.total_count,
          :vehicle_type => vehicle_type.try(:to_s),
          :primary_fta_mode_type => primary_mode.try(:to_s),
          :manufacture_year => row.get_manufacture_year,
          :pcnt_capital_responsibility => row.get_pcnt_capital_responsibility,
          :estimated_cost => row.get_scheduled_replacement_cost,
          :estimated_cost_year => row.get_scheduled_replacement_year,
          :useful_life_benchmark => row.useful_life_benchmark,
          :useful_life_remaining => row.useful_life_remaining,
          :secondary_fta_mode_types => row.get_secondary_fta_mode_types.pluck(:code).join('; '),
          :vehicle_object_key => row.object_key,
          :notes => row.notes
      }

      # calculate the additional properties and merge them into the results
      # hash
      fleets << NtdServiceVehicleFleet.new(service_fleet)
    end
    fleets
  end

  def facilities(orgs)
    start_date = start_of_fiscal_year(@report.ntd_form.fy_year)
    end_date = fiscal_year_end_date(start_of_fiscal_year(@report.ntd_form.fy_year))

    search = {organization_id: orgs.ids}
    search[Rails.application.config.asset_seed_class_name.foreign_key] = Rails.application.config.asset_seed_class_name.constantize.where('class_name LIKE ?', "%Facility%").ids
    result = @types[:facilities].constantize.operational.where(search)
    result += @types[:facilities].constantize.where(disposition_date: start_date..end_date).where(search)

    facilities = []
    result.each { |row|
      primary_mode = check_seed_field(row, 'primary_fta_mode_type')
      facility_type = check_seed_field(row, 'fta_facility_type')
      condition_update = row.condition_updates.where('event_date >= ? AND event_date <= ?', start_date, end_date).last
      facility = {
          :facility_id => row.ntd_id,
          :name => row.asset_tag,
          :part_of_larger_facility => row.section_of_larger_facility,
          :address => row.address1,
          :city => row.city,
          :state => row.state,
          :zip => row.zip,
          :latitude => row.geometry.nil? ? nil : row.geometry.y,
          :longitude => row.geometry.nil? ? nil : row.geometry.x,
          :primary_mode => primary_mode.try(:to_s),
          :secondary_mode => row.secondary_fta_mode_types.pluck(:code).join('; '),
          :private_mode => row.fta_private_mode_type.to_s,
          :facility_type => facility_type.to_s,
          :year_built => row.rebuild_year.nil? ? row.manufacture_year : row.rebuild_year ,
          :size => row.facility_size,
          :size_type => row.facility_size_unit,
          :pcnt_capital_responsibility => row.pcnt_capital_responsibility,
          :reported_condition_rating => condition_update ? (condition_update.assessed_rating+0.5).to_i : nil,
          :reported_condition_date => condition_update ? condition_update.event_date : nil,
          #:parking_measurement => row.num_parking_spaces_public, # maybe can remove
          #:parking_measurement_unit => 'Parking Spaces', #maybe can remove
          :facility_object_key => row.object_key,
          :notes => row.description
      }

      facilities << NtdFacility.new(facility)
    }

    facilities
  end

  def infrastructures(orgs)
    if Rails.application.config.asset_base_class_name == 'TransamAsset'
      start_date = start_of_fiscal_year(@report.ntd_form.fy_year)
      end_date = fiscal_year_end_date(start_of_fiscal_year(@report.ntd_form.fy_year))

      tangent_curve_track_types = FtaTrackType.where(name: ["Tangent - Revenue Service",
                                                "Curve - Revenue Service",
                                                "Non-Revenue Service"])
      special_work_track_types = FtaTrackType.where(name: ["Double diamond crossover",
                                                      "Single crossover",
                                                      "Half grand union",
                                                      "Single turnout",
                                                      "Grade crossing"])

      infrastructures = []

      infrastructure_assets = Infrastructure
                   .where(organization_id: orgs.ids, dispostion_date: (start_date..end_date))
                   .joins('INNER JOIN assets_fta_mode_types ON assets_fta_mode_types.transam_asset_type = "Infrastructure" AND assets_fta_mode_types.transam_asset_id = infrastructures.id AND assets_fta_mode_types.is_primary=1')
                   .joins('INNER JOIN assets_fta_service_types ON assets_fta_service_types.transam_asset_type = "Infrastructure" AND assets_fta_service_types.transam_asset_id = infrastructures.id AND assets_fta_service_types.is_primary=1')


      result = infrastructure_assets.group('assets_fta_mode_types.fta_mode_type_id', 'assets_fta_service_types.fta_service_type_id', 'transit_assets.fta_type_type', 'transit_assets.fta_type_id').pluck('assets_fta_mode_types.fta_mode_type_id', 'assets_fta_service_types.fta_service_type_id', 'transit_assets.fta_type_type', 'transit_assets.fta_type_id')

      result.each do |row|
        selected_infrastructures = infrastructure_assets.where(assets_fta_mode_types: {fta_mode_type_id: row[0]}, assets_fta_service_types: {fta_service_type_id: row[1]}, fta_type_type: row[2], fta_type_id: row[3])
        selected_infrastructures_count = selected_infrastructures.count

        primary_mode = check_seed_field(selected_infrastructures.first, 'primary_fta_mode_type')
        primary_tos = check_seed_field(selected_infrastructures.first, 'primary_fta_service_type')
        fta_type = check_seed_field(selected_infrastructures.first, 'fta_type')

        miles = selected_infrastructures.where.not(to_segment: nil).sum('to_segment - from_segment')

        infrastructure = {
            fta_mode: primary_mode.try(:to_s),
            fta_service_type: primary_tos.try(:to_s),
            fta_type: fta_type.try(:to_s),
            size: (special_work_track_types.include? fta_type) ? selected_infrastructures_count : nil,
            linear_miles: fta_type.class.to_s == 'FtaGuidewayType' ? miles : nil,
            track_miles: (tangent_curve_track_types.include? fta_type) ? miles : nil,
            expected_service_life: selected_infrastructures.first.policy_analyzer.get_min_service_life_months,
            pcnt_capital_responsibility: (selected_infrastructures.sum(:pcnt_capital_responsibility) / selected_infrastructures_count.to_f + 0.5).to_i,
            shared_capital_responsibility_organization: Organization.find_by(id: selected_infrastructures.group(:shared_capital_responsibility_organization_id).order('count_org DESC').pluck('shared_capital_responsibility_organization_id', 'COUNT(*) AS count_org').first[0]).to_s,
            allocation_unit: fta_type.class.to_s == 'FtaTrackType' ? nil :'%',
        }

        unless fta_type.class.to_s == 'FtaTrackType'
          components = InfrastructureComponent.where(parent_id: selected_infrastructures.ids).where('YEAR(in_service_date) <= ?', 2019)
          components_cost = components.sum(:purchase_cost)

          selected_components = components.where('YEAR(in_service_date) IN (?)', 1800..1929)
          if selected_components.count > 0
            if components_cost > 0
              year_ranges = [(selected_components.sum(:purchase_cost) * 100.0 / components_cost + 0.5).to_i]
            else
              year_ranges = [0]
            end
          else
            year_ranges = [nil]
          end

          [1930,1940,1950, 1960, 1970, 1980, 1990, 2000, 2010].each do |years|
            selected_components = components.where('YEAR(in_service_date) IN (?)', years..years+9)
            if selected_components.count > 0
              if components_cost > 0
                year_ranges << (selected_components.sum(:purchase_cost) * 100.0 / components_cost + 0.5).to_i
              else
                year_ranges << 0
              end
            else
              year_ranges << nil
            end
          end

          infrastructure = infrastructure.merge({
              pre_nineteen_thirty: year_ranges[0],
              nineteen_thirty: year_ranges[1],
              nineteen_forty: year_ranges[2],
              nineteen_fifty: year_ranges[3],
              nineteen_sixty: year_ranges[4],
              nineteen_seventy: year_ranges[5],
              nineteen_eighty: year_ranges[6],
              nineteen_ninety: year_ranges[7],
              two_thousand: year_ranges[8],
              two_thousand_ten: year_ranges[9]
          })
        end

        infrastructures << NtdInfrastructure.new(infrastructure)
      end

      infrastructures

    end
  end

  def performance_measures(orgs)

    performance_measures = []

    FtaAssetCategory.all.each do |fta_asset_category|
      tam_group = TamGroup.joins(:tam_policy, :fta_asset_categories).where(tam_policies: {fy_year: @report.ntd_form.fy_year}, tam_groups: {organization_id: orgs.ids, state: 'activated'}, fta_asset_categories: {id: fta_asset_category.id}).first

      if tam_group
        tam_group.tam_performance_metrics.each do |tam_metric|
          if fta_asset_category.name == 'Infrastructure'
            assets = Track.where(organization_id: orgs.ids)

            pcnt_performance = PerformanceRestrictionUpdateEvent.where(transam_asset: assets).where.not(to_segment: nil).sum('to_segment - from_segment') * 100.0 / assets.where.not(to_segment: nil).sum('to_segment - from_segment')
          else
            if fta_asset_category.name == 'Facilities'
              asset_count = tam_group.assets(fta_asset_category).where(fta_asset_class: tam_metric.asset_level).count
            else
              asset_count = tam_group.assets(fta_asset_category).where(fta_type: tam_metric.asset_level).count
            end

            pcnt_performance = tam_group.assets_past_useful_life_benchmark(fta_asset_category, tam_metric) * 100.0 / asset_count
          end


          performance_measures << NtdPerformanceMeasure.new(
              fta_asset_category: fta_asset_category,
              asset_level: tam_metric.asset_level.try(:code) ? "#{tam_metric.asset_level.code} - #{tam_metric.asset_level.name}" : tam_metric.asset_level.name,
              pcnt_goal: tam_metric.pcnt_goal,
              pcnt_performance: pcnt_performance
          )
        end
      end
    end

    performance_measures

  end
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  def check_seed_field(row, field_name)

    data = row.try(:asset_fleet_type).present? ? row.send("get_#{field_name}") : row.send(field_name)

    if data.try(:name) == 'Unknown'
        if row.try(:asset_fleet_type).present?
          @process_log.add_processing_message(1, 'info', "<a href='#{Rails.application.routes.url_helpers.asset_fleet_path(row)}'>#{Rails.application.config.asset_seed_class_name.constantize.find_by(class_name: row.asset_fleet_type.class_name)} - Fleet #{row.ntd_id}</a>")
        else
          @process_log.add_processing_message(1, 'info', "<a href='#{Rails.application.routes.url_helpers.inventory_path(row)}'>#{row.send(Rails.application.config.asset_seed_class_name.underscore)} #{row.asset_tag}</a>")
        end
      @process_log.add_processing_message(2, 'warning', "#{field_name.humanize} is Unknown.")
    end

    data
  end


end
