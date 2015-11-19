#------------------------------------------------------------------------------
#
# ServiceLifeAgeOrMileage
#
#------------------------------------------------------------------------------
class ServiceLifeConditionOrMileage < ServiceLifeTransitCalculator

  # Calculates the last year for service based on the minimum of the asset
  # condition or the mileage
  def calculate(asset)

    Rails.logger.debug "ServiceLifeConditionOrMileage.calculate(asset)"

    # get the expected last year of service based on condition
    last_year_by_condition = by_condition(asset)

    # get the predicted last year of service based on the asset mileage if vehicle
    last_year_by_mileage = by_mileage(asset)

    # return the minimum of the two
    [last_year_by_condition, last_year_by_mileage].min
  end

end
