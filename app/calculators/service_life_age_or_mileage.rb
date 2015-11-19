#------------------------------------------------------------------------------
#
# ServiceLifeAgeOrdMileage
#
#------------------------------------------------------------------------------
class ServiceLifeAgeOrMileage < ServiceLifeTransitCalculator

  # Calculates the last year for service based on the first year that age or
  # mileage is exceeded
  def calculate(asset)

    Rails.logger.debug "ServiceLifeAgeOrMileage.calculate(asset)"

    # get the expected last year of service based on age
    last_year_by_age = by_age(asset)

    # get the predicted last year of service based on the asset mileage if vehicle
    last_year_by_mileage = by_mileage(asset)

    # return the minimum of the two
    [last_year_by_age, last_year_by_mileage].min
  end

end
