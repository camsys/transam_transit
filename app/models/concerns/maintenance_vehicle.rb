module MaintenanceVehicle
  #------------------------------------------------------------------------------
  #
  # MaintenanceVehicle
  #
  # Mixin that adds vehicle maintenance properties to an Asset
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    # each asset has zero or more condition updates
    has_many   :maintenance_updates, -> {where :asset_event_type_id => MaintenanceUpdateEvent.asset_event_type.id }, :class_name => "VehicleMaintenanceUpdateEvent"

    # ----------------------------------------------------
    # Validations
    # ----------------------------------------------------

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Forces an update of an assets reported condition. This performs an update on the record.
  def update_maintenance

    Rails.logger.debug "Updating maintenance for asset = #{object_key}"

    # can't do this if it is a new record as none of the IDs would be set
    unless new_record? or disposed?
      if maintenance_updates.empty?
        self.last_maintenance_date = nil
      else
        event = maintenance_updates.last
        self.last_maintenance_date = event.event_date
      end
      # save changes to this asset
      if self.changed?
        save(:validate => false)
      end
    end

  end

end
