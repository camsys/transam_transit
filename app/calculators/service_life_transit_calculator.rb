#------------------------------------------------------------------------------
#
# ServiceLifeTransitCalculator
#
# Adds by_mileage(asset) to the base ServiceLifeCalculator class
#
#------------------------------------------------------------------------------
class ServiceLifeTransitCalculator < ServiceLifeCalculator

  protected
  # Calculate the service life based on the minimum miles if the
  # asset has a maximum number of miles set
  def by_mileage(asset)

    if asset.type_of? :vehicle or asset.type_of? :support_vehicle

      # Iterate over all the mileage update events from earliest to latest
      # and find the first year (if any) that the  policy replacement became
      # effective
      max_service_life_miles = asset.policy_analyzer.get_max_service_life_miles
      if max_service_life_miles
        events = asset.mileage_updates(true)
        Rails.logger.debug "Found #{events.count} events."
        Rails.logger.debug "max_service_life_miles = #{max_service_life_miles}."
        events.each do |event|
          Rails.logger.debug "Event date = #{event.event_date}, Mileage = #{event.current_mileage}"
          if event.current_mileage >= max_service_life_miles
            Rails.logger.debug "returning #{fiscal_year_year_on_date(event.event_date)}"
            return fiscal_year_year_on_date(event.event_date)
          end
        end
      end
    end

    # if we didn't find a mileage event that would make the policy effective
    # we can simply return the age constraint
    Rails.logger.debug "returning value from policy age"

    by_age(asset)

  end

end
