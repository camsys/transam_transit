class FixTransitAssetTypesView < ActiveRecord::Migration[5.2]
  def change
    all_user_roles_view = <<-SQL
      DROP VIEW if exists transit_asset_types_view;
      CREATE OR REPLACE VIEW transit_asset_types_view AS
          SELECT ta.id, concat(ta.fta_type_type, '_', ta.fta_type_id) as fta_type_type_id,concat(COALESCE(fvt.name, ''), COALESCE(fsvt.name, ''), COALESCE(fft.name, ''), COALESCE(fet.name, ''),  COALESCE(fgt.name, ''),  COALESCE(ftrt.name, ''),  COALESCE(fpst.name, '')) as fta_type FROM transit_assets as ta 
          left join fta_vehicle_types as fvt on fvt.id = ta.fta_type_id and ta.fta_type_type = 'FtaVehicleType'
          left join fta_support_vehicle_types as fsvt on fsvt.id = ta.fta_type_id and ta.fta_type_type = 'FtaSupportVehicleType'
          left join fta_facility_types as fft on fft.id = ta.fta_type_id and ta.fta_type_type = 'FtaFacilityType'
          left join fta_equipment_types as fet on fet.id = ta.fta_type_id and ta.fta_type_type = 'FtaEquipmentType'
          left join fta_guideway_types as fgt on fgt.id = ta.fta_type_id and ta.fta_type_type = 'FtaGuidewayType'
          left join fta_track_types as ftrt on ftrt.id = ta.fta_type_id and ta.fta_type_type = 'FtaTrackType'
          left join fta_power_signal_types as fpst on fpst.id = ta.fta_type_id and ta.fta_type_type = 'FtaPowerSignalType';
    SQL
    ActiveRecord::Base.connection.execute all_user_roles_view
  end
end
