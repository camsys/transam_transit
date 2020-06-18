class UpdateNtdSeedData < ActiveRecord::DataMigration
  def up
    # ---------------------------------------------------------------------------------
    # update fta vehicle types
    fta_vehicle_types = FtaVehicleType.where(code: ['MB', 'RT'])
    other_fta_vehicle_type = FtaVehicleType.unscoped.find_by(name: 'Other')
    TransitAsset.where(fta_type: fta_vehicle_types).update_all(fta_type_id: other_fta_vehicle_type.id)
    fta_vehicle_types.destroy_all
    # ---------------------------------------------------------------------------------

    # ---------------------------------------------------------------------------------
    # update fta track types
    FtaTrackType.find_by(name: 'Double diamond crossover').update!(name: 'Double crossover')
    half_grand_union = FtaTrackType.find_by(name: 'Half grand union')
    TransitAsset.where(fta_type: half_grand_union).update_all(fta_type_id: FtaTrackType.find_by(name: 'Single turnout').id)
    half_grand_union.destroy!

    fta_track_types = [
        {name: 'Tangent - Revenue Service', active: true, :fta_asset_class => 'Track', sort_order: 15},
        {name: 'Curve - Revenue Service', active: true, :fta_asset_class => 'Track', sort_order: 16},
        {name: 'Non-Revenue Service', active: true, :fta_asset_class => 'Track', sort_order: 17},
        {name: 'Revenue Track - No Capital Replacement Responsibility', active: true, :fta_asset_class => 'Track', sort_order: 18},
        {name: 'Double crossover', active: true, :fta_asset_class => 'Track', sort_order: 19},
        {name: 'Single crossover', active: true, :fta_asset_class => 'Track', sort_order: 20},
        {name: 'Single turnout', active: true, :fta_asset_class => 'Track', sort_order: 21},
        {name: 'Lapped turnout', active: true, :fta_asset_class => 'Track', sort_order: 22},
        {name: 'Grade crossing', active: true, :fta_asset_class => 'Track', sort_order: 23},
        {name: 'Rail crossings', active: true, :fta_asset_class => 'Track', sort_order: 24},
        {name: 'Slip switch', active: true, :fta_asset_class => 'Track', sort_order: 25},
    ]
    fta_track_types.each do |track_type|
      f = FtaTrackType.find_or_create_by(name: track_type[:name])
      f.update!(track_type.except(:fta_asset_class))
    end
    # ---------------------------------------------------------------------------------

    # ---------------------------------------------------------------------------------
    # add fta facility type
    FtaFacilityType.create!({:active => 1, :class_name => 'TransitFacility', :name => 'Ferryboat Terminal',     :description => 'Ferryboat Terminal.', :fta_asset_class => FtaAssetClass.find_by(name: 'Passenger')})
  end
end