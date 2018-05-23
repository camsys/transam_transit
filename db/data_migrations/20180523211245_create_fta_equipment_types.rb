class CreateFtaEquipmentTypes < ActiveRecord::DataMigration
  def up
    fta_asset_class_id = FtaAssetClass.find_by(name: 'Capital Equipment').id

    fta_equipment_types = [
        {name: 'Bus Benches', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Bus Lift', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Bus Shelter', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Bus Stop Signage', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Communications Equipment, Mobile Radios, Base Stations', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Computer Hardware', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Computer Software', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Fare Boxes', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Mobile Data Computers (real-time dispatching)', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Office Furniture', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Security/Surveillance Equipment, Cameras', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Shop Equipment-Alignment Machines, Bus Washing, Tire Changers', fta_asset_class_id: fta_asset_class_id, active: true},
    ]

    fta_equipment_types.each do |type|
      FtaEquipmentType.create!(type)
    end
  end
end