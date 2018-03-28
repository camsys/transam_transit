class CleanupFtaVehicleTypes < ActiveRecord::DataMigration
  def up

    # add new types if they don't exist
    [{:active => 1, :name => 'Minibus', :code => 'MB',  :description => 'Minibus.'},
     {:active => 1, :name => 'Rubber Tired Vintage Trolley',:code => 'RT',  :description => 'Rubber Tired Vintage Trolley.'},
     {:active => 1, :name => 'Streetcar',:code => 'SR',  :description => 'Streetcar.'}].each do |row|
      FtaVehicleType.create!(row) unless FtaVehicleType.find_by(name: row[:name]).present?
    end

    # check on other/unknown
    other = FtaVehicleType.find_by(name: 'Other')
    unknown = FtaVehicleType.find_by(name: 'Unknown')

    if other.present?
      if unknown.present?
        Asset.where(fta_vehicle_type_id: unknown.id).update_all(fta_vehicle_type_id: other.id)
        unknown.destroy!
      # else do nothing
      end
    else
      if unknown.present?
        FtaVehicleType.find_by(name: 'Unknown').update!(name: 'Other', code: 'OR')
      else
        FtaVehicleType.create!({:name=>"Other",
                                :code=>"OR",
                                :description=>"Vehicle type not specified.",
                                :active=>true})
      end
    end

    # remove old types
    updated_assets = Asset.where(fta_vehicle_type_id: FtaVehicleType.where(name: ['Taxicab Sedan', 'Taxicab Van', 'Taxicab Station Wagon']).ids)
    updated_assets.update_all(fta_vehicle_type_id: FtaVehicleType.find_by(name: 'Other').id)
    puts "#{updated_assets.count} updated to 'Other' for removed FTA vehicle types"
    FtaVehicleType.where(name: ['Taxicab Sedan', 'Taxicab Van', 'Taxicab Station Wagon']).destroy_all

  end
end