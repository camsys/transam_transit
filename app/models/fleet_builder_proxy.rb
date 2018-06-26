# this class is no longer used other than the variables depicting the different types of actions
# leaving code since already written and can be reused if the builder ever needs to be converted back to form


class FleetBuilderProxy < Proxy

  RESET_ALL_ACTION            = 0         # clear out all existing fleets and rebuilt
  USE_EXISTING_FLEET_ACTION   = 1         # add new assets to existing fleets
  NEW_FLEETS_ACTION           = 2         # add new assets to new fleets

  # General state variables

  # organization
  attr_accessor     :organization_id

  # Type of asset type to process
  attr_accessor     :asset_fleet_types

  attr_accessor     :action

  # Basic validations. Just checking that the form is complete
  #validates :asset_fleet_types, :presence => true

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    self.asset_fleet_types ||= []
  end

end
