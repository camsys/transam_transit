class AddFtaEquipmentTypePassengerAmenities < ActiveRecord::DataMigration
  def up
    # we have to shift everything down in the seed and update assets

    # take the ones after the new Passenger Amenities we're adding in desc order
    list = [
            "Miscellaneous",
            "Electrification / Power Distribution",
            "Lanscaping/Public Art",
    ]

    list.each_with_index do |name, idx|
      equipment_type = FtaEquipmentType.find_by(name: name)
      CapitalEquipment.where(fta_type: equipment_type).update_all(fta_type_id: equipment_type.id + 1)
      equipment_type.update(id: equipment_type.id + 1)
    end

    FtaEquipmentType.create!({id: FtaEquipmentType.find_by(name: 'Signage').id + 1, name: 'Passenger Amenities', fta_asset_class_id: FtaAssetClass.find_by(name: 'Capital Equipment').id, active: true})

  end
end