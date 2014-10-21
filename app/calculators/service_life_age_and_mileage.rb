#------------------------------------------------------------------------------
#
# ServiceLifeAgeAndMileage
#
#------------------------------------------------------------------------------
class ServiceLifeAgeAndMileage < ServiceLifeCalculator

  # Calculates the last year for service based on the minimum of the average asset
  # service life or the condition
  def calculate(asset)

    Rails.logger.debug "ServiceLifeAgeAndMileage.calculate(asset)"

    # get the expected last year of service based on age
    last_year_by_age = by_age(asset)

    # get the predicted last year of service based on the asset mileage if vehicle
    last_year_by_mileage = by_mileage(asset)

    # return the minimum of the two
    [last_year_by_age, last_year_by_mileage].min
  end

  protected
  # Calculate the service life based on the minimum miles if the
  # asset has a maximum number of miles set
  def by_mileage(asset)
    if asset.type_of? :vehicle or asset.type_of? :support_vehicle
      # Iterate over all the mileage update events from earliest to latest
      # and find the first year (if any) that the  policy replacement became
      # effective
      policy_item = asset.policy_rule
      if policy_item.max_service_life_miles
        events = asset.mileage_updates(true)
        Rails.logger.debug "Found #{events.count} events."
        Rails.logger.debug "max_service_life_miles = #{policy_item.max_service_life_miles}."
        events.each do |event|
          Rails.logger.debug "Event date = #{event.event_date}, Mileage = #{event.current_mileage}"
          if event.current_mileage >= policy_item.max_service_life_miles
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
