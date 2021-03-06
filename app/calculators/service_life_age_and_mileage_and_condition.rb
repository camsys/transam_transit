#------------------------------------------------------------------------------
#
# ServiceLifeAgeAndMileageAndCondition
#
#------------------------------------------------------------------------------
class ServiceLifeAgeAndMileageAndCondition < ServiceLifeTransitCalculator

  # Calculates the last year for service based on the first year when all of
  # the conditions will be met
  def calculate(asset)

    Rails.logger.debug "ServiceLifeAgeAndMileageAndCondition.calculate(asset)"

    # get the expected last year of service based on age
    last_year_by_age = by_age(asset)

    # get the expected last year of service based on condition
    last_year_by_condition = by_condition(asset)

    # get the predicted last year of service based on the asset mileage if vehicle
    last_year_by_mileage = by_mileage(asset)

    # return the minimum of the two
    [last_year_by_age, last_year_by_condition, last_year_by_mileage].max
  end

end
