#------------------------------------------------------------------------------
#
# TermEstimationCalculator
#
#------------------------------------------------------------------------------
class TermEstimationCalculator < ConditionEstimationCalculator

  # Estimates the condition rating of an asset using approximations of
  # TERM condition decay splines. The condition is only associated with
  # the age of the asset
  #
  def calculate(asset)

    Rails.logger.debug "TERMEstimationCalculator.calculate(asset)"

    years = asset.age

    if asset.type_of? :vehicle
      if years <= 3
        return -1.75 / 3 * years + 5 + 1.75 / 3
      else
        return 3.29886 * Math.exp(-0.0178422 * years)
      end
    elsif asset.type_of? :rail_car
      if years <= 2.5
        return -3.75 / 5 * years + 5 + 3.75 / 5
      else
        return 4.54794 * Math.exp(-0.0204658 * years)
      end
    elsif asset.type_of? :support_facility
      if years <= 18
        return 5.08593 * Math.exp(-0.0196381 * years)
      elsif years <= 19
        return -2.08 / 5 * years + 11.236
      else
        return 3.48719 * Math.exp(-0.0042457 * years)
      end
    elsif asset.type_of? :transit_facility
      return scaled_sigmoid(6.689 - 0.255 * years)

    elsif asset.type_of? :fixed_guideway
      return 4.94961 * Math.exp(-0.0162812 * years)

    else
      # If we don't have a term curve then default to a Straight Line Estimation
      slc = StraightLineEstimationCalculator.new
      return slc.calculate(asset)
    end

  end

  # Estimates the last servicable year for the asset based on the TERM Decay curves
  def last_servicable_year(asset)

    Rails.logger.debug "TERMEstimationCalculator.last_servicable_year(asset)"

    years = asset.age
    condition_threshold = asset.policy.condition_threshold

    last_condition = calculate(asset)

    while last_condition > condition_threshold
      years += 1

      if asset.type_of? :vehicle
        if years <= 3
          last_condition = -1.75 / 3 * years + 5 + 1.75 / 3
        else
          last_condition = 3.29886 * Math.exp(-0.0178422 * years)
        end
      elsif asset.type_of? :rail_car
        if years <= 2.5
          last_condition = -3.75 / 5 * years + 5 + 3.75 / 5
        else
          last_condition = 4.54794 * Math.exp(-0.0204658 * years)
        end
      elsif asset.type_of? :support_facility
        if years <= 18
          last_condition = 5.08593 * Math.exp(-0.0196381 * years)
        elsif years <= 19
          last_condition = -2.08 / 5 * years + 11.236
        else
          last_condition = 3.48719 * Math.exp(-0.0042457 * years)
        end
      elsif asset.type_of? :transit_facility
        last_condition = scaled_sigmoid(6.689 - 0.255 * years)

      elsif asset.type_of? :fixed_guideway
        last_condition = 4.94961 * Math.exp(-0.0162812 * years)

      else
        # If we don't have a term curve then default to a Straight Line Estimation
        slc = StraightLineEstimationCalculator.new
        last_condition = slc.calculate(asset)
      end
    end

    [asset.manufacture_year + years, fiscal_year_year_on_date(Date.today)].max

  end

  protected
    def scaled_sigmoid(val)
      x = Math.exp(val)
      return x / (1.0 + x) * 4 + 1
    end

    def scaled_sigmoid_inverse(val)
      return Math.log((5 - val) / (val - 1))
    end

end
