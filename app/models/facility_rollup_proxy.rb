#-------------------------------------------------------------------------------
# MessageProxy
#
# Proxy class for gathering new message data
#
#-------------------------------------------------------------------------------
class FacilityRollupProxy < Proxy

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------

  attr_accessor :facility_rollup_asset_type_proxies


  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    [
        :facility_rollup_asset_type_proxies_attributes => [FacilityRollupAssetTypeProxy.allowable_params]
    ]
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  def facility_rollup_asset_type_proxies_attributes=(attributes)
    @facility_rollup_asset_type_proxies ||= []
    attributes.each do |i, proxy_params|
      @facility_rollup_asset_type_proxies.push(FacilityRollupAssetTypeProxy.new(proxy_params))
    end
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

end
