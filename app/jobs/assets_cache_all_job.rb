#------------------------------------------------------------------------------
# Ensure that all TransamAssets are in the inventory_api cache
#------------------------------------------------------------------------------
class AssetsCacheAllJob < Job
  def run
    [RevenueVehicle, ServiceVehicle, Facility, CapitalEquipment].each do |klass|
      klass.all.each do |asset|
        key = "#{asset.cache_key_with_version}/inventory_api"
        unless Rails.cache.exist?(key)
          Rails.cache.write(key, asset.very_specific.inventory_api_json)
        end
      end
    end
  end

  def prepare
    @logger = Delayed::Worker.logger || Rails.logger
    @logger.debug "Executing AssetsCacheAllJob at #{Time.now.to_s} for all assets"
  end
end