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

    # get the predicted last year of service based on the asset mileage
    if asset.type_of? :vehicle or asset.type_of? :support_vehicle
      last_year_by_mileage = by_mileage(asset)
    else
      last_year_by_mileage = 9999
    end
    
    # return the minimum of the two
    [last_year_by_age, last_year_by_mileage].min
  end
  
  protected
  # Calculate the service life based on the minimum miles if the
  # asset has a maximum number of miles set
  def by_mileage(asset)

    # Set the default maximum
    year = 9999
    unless asset.type_of? :vehicle or asset.type_of? :support_vehicle
      # Iterate over all the mileage update events from earliest to latest
      # and find the first year (if any) that the  policy replacement became
      # effective
      policy_item = @policy.get_rule(asset)
      if policy_item.max_service_life_miles
        events = asset.mileage_updates(true)
        Rails.logger.debug "Found #{events.count} events."
        Rails.logger.debug "max_service_life_miles = #{policy_item.max_service_life_miles}."
        events.each do |event|
          Rails.logger.debug "Event date = #{event.event_date}, Mileage = #{event.current_mileage}"
          if event.current_mileage >= policy_item.max_service_life_miles
            Rails.logger.debug "returning #{event.event_date.year}"
            year = event.event_date.year
            break
          end
        end
      end
    end    
    year
  end  
  
end