class ServiceVehicle < ApplicationRecord
  acts_as :transit_asset, as: :transit_assetible
  actable as: :service_vehiclible

  belongs_to :chassis
  belongs_to :fuel_type
  belongs_to :dual_fuel_type
  belongs_to :ramp_manufacturer
end
