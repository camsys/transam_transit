class SetDefaultPrimaryModeServiceType < ActiveRecord::DataMigration
  def up
    # cleanup existing data for FTA Mode types and Service types
    unknown_mode = FtaModeType.find_by(code: 'XX')
    unknown_service_type = FtaServiceType.find_by(code: 'XX')

    ['Vehicle', 'SupportVehicle', 'TransitFacility', 'SupportFacility'].each do |klass|
      klass.constantize.all.each do |asset|
        mode = asset.assets_fta_mode_types.first
        if mode
          mode.update_columns(is_primary: true)
        else
          asset.assets_fta_mode_types.create!(asset: asset, fta_mode_type: unknown_mode, is_primary: true)
        end

        if klass == 'Vehicle'
          service_type = asset.assets_fta_service_types.first
          if service_type
            service_type.update_columns(is_primary: true)
          else
            asset.assets_fta_service_types.create!(asset: asset, fta_service_type: unknown_service_type, is_primary: true)
          end
        end
      end
    end

  end
end