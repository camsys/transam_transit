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

    if asset.respond_to? :mileage_updates

      # Iterate over all the mileage update events from earliest to latest
      # and find the first year (if any) that the  policy replacement became
      # effective
      min_service_life_miles = asset.policy_analyzer.get_min_service_life_miles
      if min_service_life_miles

        #-----------------------------------------------------------------------
        # If the asset has been rehabilitated check to see there are additional
        # service miles required
        #-----------------------------------------------------------------------
        if asset.last_rehabilitation_date.present?
          min_service_life_miles += asset.policy_analyzer.extended_service_life_miles.to_i
        end

        events = asset.mileage_updates(true)
        #Rails.logger.debug "Found #{events.count} events."
        #Rails.logger.debug "min_service_life_miles = #{min_service_life_miles}."
        events.each do |event|
          #Rails.logger.debug "Event date = #{event.event_date}, Mileage = #{event.current_mileage}"
          if event.current_mileage >= min_service_life_miles
            #Rails.logger.debug "returning #{fiscal_year_year_on_date(event.event_date)}"
            return fiscal_year_year_on_date(event.event_date)
          end
        end
      end
    end

    # if we didn't find a mileage event that would make the policy effective
    # we can simply return the age constraint
    Rails.logger.debug "returning value from policy age"

    last_year_by_age = by_age(asset)

    if last_year_by_age <= current_planning_year_year
     last_year_by_age + 1
    else
      last_year_by_age
    end

  end

end
