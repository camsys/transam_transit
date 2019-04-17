class AddFtaEquipmentTypes < ActiveRecord::DataMigration
  def up
    fta_asset_class_id = FtaAssetClass.find_by(name: 'Capital Equipment').id

    fta_equipment_types = [
        {name: 'Fare Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Maintenance Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Facility Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'IT Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Office Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Communications Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Security/Surveillance Equipment', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Bus Shelter', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Signage', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Lanscaping/Public Art', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Electrification / Power Distribution', fta_asset_class_id: fta_asset_class_id, active: true},
        {name: 'Miscellaneous', fta_asset_class_id: fta_asset_class_id, active: true},
    ]

    fta_equipment_types.each do |type|
      FtaEquipmentType.create!(type)
    end
  end
end