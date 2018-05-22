class RevenueVehicle < ApplicationRecord
  acts_as :service_vehicle, as: :service_vehiclible

  belongs_to :esl_category
  belongs_to :fta_funding_type
  belongs_to :fta_ownership_type
end
