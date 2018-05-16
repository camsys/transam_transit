module TransamFleetable
  #------------------------------------------------------------------------------
  #
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    # ----------------------------------------------------
    # Callbacks
    # ----------------------------------------------------

    after_save :check_fleet

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    has_many :assets_asset_fleets, :foreign_key => :asset_id

    has_and_belongs_to_many :asset_fleets, :through => :assets_asset_fleets, :join_table => 'assets_asset_fleets', :foreign_key => :asset_id

    # ----------------------------------------------------
    # Validations
    # ----------------------------------------------------

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  module ClassMethods

  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def fiscal_year_mileage(fy_year=nil)
    fy_year = current_fiscal_year_year if fy_year.nil?

    last_date = start_of_fiscal_year(fy_year+1) - 1.day
    mileage_updates.where(event_date: last_date).last.try(:current_mileage)
  end

  protected

  def check_fleet
    asset_fleets.each do |fleet|
      fleet_type = fleet.asset_fleet_type

      # only need to check on an asset which is still valid in fleet
      if self.assets_asset_fleets.find_by(asset_fleet: fleet).active

        if fleet.active_assets.count == 1 && fleet.active_assets.first.object_key == self.object_key # if the last valid asset in fleet
          # check all other assets to see if they now match the last active fleet whose changes are now the fleets grouped values
          fleet.assets.where.not(id: self.id).each do |asset|
            typed_asset = Asset.get_typed_asset(asset)
            if asset.attributes.slice(*fleet_type.standard_group_by_fields) == self.attributes.slice(*fleet_type.standard_group_by_fields)
              is_valid = true
              fleet_type.custom_group_by_fields.each do |field|
                if typed_asset.send(field) != self.send(field)
                  is_valid = false
                  break
                end
              end

              AssetsAssetFleet.find_by(asset: asset, asset_fleet: fleet).update(active: is_valid)
            end
          end
        else
          if (self.previous_changes.keys & fleet_type.standard_group_by_fields).count > 0
            AssetsAssetFleet.find_by(asset: self, asset_fleet: fleet).update(active: false)
          else # check custom fields
            asset_to_follow = Asset.get_typed_asset(fleet.active_assets.where.not(id: self.id).first)

            fleet_type.custom_group_by_fields.each do |field|
              if asset_to_follow.send(field) != self.send(field)
                AssetsAssetFleet.find_by(asset: self, asset_fleet: fleet).update(active: false)
                break
              end
            end
          end
        end
      end
    end

    return true
  end

end
