class SetDefaultModeServiceTypeRail < ActiveRecord::DataMigration
  def up
    if Rails.application.config.transam_transit_rail == true
      # cleanup existing data for FTA Mode types and Service types
      unknown_mode = FtaModeType.find_by(code: 'XX')
      unknown_service_type = FtaServiceType.find_by(code: 'XX')

      ['RailCar', 'Locomotive'].each do |klass|
        klass.constantize.all.each do |asset|
          mode = asset.assets_fta_mode_types.first
          if mode
            mode.update_columns(is_primary: true)
          else
            asset.assets_fta_mode_types.create!(asset: asset, fta_mode_type: unknown_mode, is_primary: true)
          end

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