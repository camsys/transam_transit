class ServiceVehicle < ApplicationRecord
  acts_as :transit_asset, as: :transit_assetible
  actable as: :service_vehiclible

  belongs_to :chassis
  belongs_to :fuel_type
  belongs_to :dual_fuel_type
  belongs_to :ramp_manufacturer

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method"
      Rails.logger.warn "You are calling the old asset for this method"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

end
