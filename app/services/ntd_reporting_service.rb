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
    @form = params[:form]
    @process_log = ProcessLog.new
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

    AssetFleet.where(organization: orgs, asset_fleet_type: AssetFleetType.find_by(class_name: 'Vehicle')).each do |row|

      primary_mode = check_seed_field(row, 'primary_fta_mode_type')
      primary_tos = check_seed_field(row, 'primary_fta_service_type')
      vehicle_type = check_seed_field(row, 'fta_vehicle_type')
      funding_type = check_seed_field(row, 'fta_funding_type')
      ownership_type = check_seed_field(row, 'fta_ownership_type')


      fleet ={
          rvi_id: row.ntd_id,
          fta_mode: "#{primary_mode.name} (#{primary_mode.code})",
          fta_service_type: "#{primary_tos.name} (#{primary_tos.code})",
          agency_fleet_id: row.agency_fleet_id,
          dedicated: row.get_dedicated,
          direct_capital_responsibility: row.get_direct_capital_responsibility,
          size: row.total_count,
          num_active: row.active_count,
          num_ada_accessible: row.ada_accessible_count,
          num_emergency_contingency: row.fta_emergency_contingency_count,
          vehicle_type: "#{vehicle_type.name} (#{vehicle_type.code})",
          manufacture_code: row.get_manufacturer.code,
          rebuilt_year: 'TO DO',
          model_number: 'TO DO',
          other_manufacturer: row.get_other_manufacturer.to_s,
          fuel_type: row.get_fuel_type.name,
          dual_fuel_type: row.get_dual_fuel_type.to_s,
          vehicle_length: 'TO DO',
          seating_capacity: 'TO DO',
          standing_capacity: 'TO DO',
          total_active_miles_in_period: row.miles_this_year,
          avg_lifetime_active_miles: row.avg_active_lifetime_miles,
          ownership_type: "#{ownership_type.name} (#{ownership_type.code})",
          funding_type: "#{funding_type.name} (#{funding_type.code})",
          notes: row.notes,
          status: row.active(@form.fy_year) ? 'Active' : 'Retired',
          useful_life_remaining: 'TO DO',
          useful_life_benchmark: 'TO DO',
          manufacture_year: row.get_manufacture_year,
          additional_fta_mode: row.get_secondary_fta_mode_type.try(:code),
          additional_fta_service_type: row.get_secondary_fta_service_type.try(:code),
          :vehicle_object_key => row.object_key
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

    AssetFleet.where(organization: orgs, asset_fleet_type: AssetFleetType.find_by(class_name: 'SupportVehicle')).each do |row|

      primary_mode = check_seed_field(row, 'primary_fta_mode_type')
      vehicle_type = check_seed_field(row, 'fta_support_vehicle_type')

      service_fleet = {
          :sv_id => row.ntd_id,
          :agency_fleet_id => row.agency_fleet_id,
          :fleet_name => row.fleet_name,
          :size => row.total_count,
          :vehicle_type => vehicle_type.to_s,
          :primary_fta_mode_type => primary_mode.to_s,
          :manufacture_year => row.get_manufacture_year,
          :pcnt_capital_responsibility => row.get_pcnt_capital_responsibility,
          :estimated_cost => row.get_scheduled_replacement_cost,
          :estimated_cost_year => row.get_scheduled_replacement_year,
          :useful_life_benchmark => 'TO DO',
          :useful_life_remaining => 'TO DO',
          :secondary_fta_mode_types => row.get_secondary_fta_mode_types.pluck(:code).join(' '),
          :vehicle_object_key => row.object_key,
          :notes => row.notes
      }

      # calculate the additional properties and merge them into the results
      # hash
      fleets << NtdServiceVehicleFleet.new(service_fleet)
    end
    fleets
  end

  def admin_and_maintenance_facilities(orgs)
    start_date = start_of_fiscal_year(@form.fy_year)
    end_date = fiscal_year_end_date(start_of_fiscal_year(@form.fy_year))

    result = FtaBuilding.where('(assets.disposition_date IS NULL AND assets.asset_tag != assets.object_key) OR (assets.disposition_date >= ? AND assets.disposition_date <= ?)', start_date, end_date).where(organization_id: orgs.ids, asset_type_id: AssetType.where(class_name: ['TransitFacility', 'SupportFacility']).pluck(:id))

    facilities = []
    result.each { |row|
      primary_mode = check_seed_field(row, 'primary_fta_mode_type')
      facility_type = check_seed_field(row, 'fta_facility_type')


      condition_update = row.condition_updates.where('event_date >= ? AND event_date <= ?', start_date, end_date).last
      facility = {
          :facility_id => 'TO DO',
          :name => row.asset_tag,
          :part_of_larger_facility => row.section_of_larger_facility,
          :address => row.address1,
          :city => row.city,
          :state => row.state,
          :zip => row.zip,
          :latitude => row.geometry.nil? ? nil : row.geometry.y,
          :longitude => row.geometry.nil? ? nil : row.geometry.x,
          :primary_mode => primary_mode.to_s,
          :secondary_mode => row.secondary_fta_mode_types.pluck(:code).join(' '),
          :private_mode => row.fta_private_mode_type.to_s,
          :facility_type => facility_type.to_s,
          :year_built => row.rebuild_year.nil? ? row.manufacture_year : row.rebuild_year ,
          :size => row.facility_size,
          :size_type => 'Square Feet',
          :pcnt_capital_responsibility => row.pcnt_capital_responsibility,
          :reported_condition_rating => condition_update ? (condition_update.assessed_rating+0.5).to_i : nil,
          :reported_condition_date => condition_update ? condition_update.event_date : nil,
          #:parking_measurement => row.num_parking_spaces_public, # maybe can remove
          #:parking_measurement_unit => 'Parking Spaces', #maybe can remove
          :facility_object_key => row.object_key,
          :notes => row.description
    }

      facilities << NtdAdminAndMaintenanceFacility.new(facility)
    }

    facilities
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
          @process_log.add_processing_message(1, 'info', "<a href='#{Rails.application.routes.url_helpers.asset_fleet_path(row)}'>#{AssetType.find_by(class_name: row.asset_fleet_type.class_name)} - Fleet #{row.ntd_id}</a>")
        else
          @process_log.add_processing_message(1, 'info', "<a href='#{Rails.application.routes.url_helpers.inventory_path(row)}'>#{row.asset_type} #{row.asset_tag}</a>")
        end
      @process_log.add_processing_message(2, 'warning', "#{field_name.humanize} is Unknown.")
    end

    data
  end


end
