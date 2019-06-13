class AddSeedDataPowerSignalAssets < ActiveRecord::DataMigration
  def up
    fta_asset_class = FtaAssetClass.find_by(class_name: 'PowerSignal')
    ['Substation Building', 'Substation Equipment', 'Third Rail/Power Distribution', 'Overhead Contact System/Power Distribution'].each do |fta_type|
      FtaPowerSignalType.create!(name: fta_type, active: true)
    end

    FtaTrackType.update_all(fta_asset_class_id: FtaAssetClass.find_by(class_name: 'Track').id)
    FtaPowerSignalType.update_all(fta_asset_class_id: fta_asset_class.id)
    FtaGuidewayType.update_all(fta_asset_class_id: FtaAssetClass.find_by(class_name: 'Guideway').id)

    asset_type = AssetType.find_by(class_name: 'PowerSignal')
    ['Substation', 'Power Equipment', 'Drive System', 'Distribution'].each do |subtype|
      AssetSubtype.create!(name: subtype, description: subtype, active: true, asset_type: asset_type)
    end

    InfrastructureSegmentType.create!({name: 'Special Track', fta_asset_class: fta_asset_class, active: true})
    InfrastructureSegmentType.find_by(name: 'Crossing')&.update!(name: 'Highway Crossing')
    InfrastructureSegmentType.find_by(name: 'Junction')&.update!(name: 'Interlocking')

    [{name: 'Contact System', fta_asset_category: fta_asset_class.fta_asset_category, fta_asset_class: fta_asset_class, active: true},
     {name: 'Power Equipment', fta_asset_category: fta_asset_class.fta_asset_category, fta_asset_class: fta_asset_class, active: true},
     {name: 'Structure', fta_asset_category: fta_asset_class.fta_asset_category, fta_asset_class: fta_asset_class, active: true}].each do |component_type|
      ComponentType.create!(component_type)
    end

    ['600 V DC', '750 V DC', '>1,200 V DC', '1,500 V DC', '3 kV DC', '12.5 kV AC, 25 Hz', '15 kV AC, 16.7 Hz', '25 kV AC, 50 Hz', '25 kV AC, 60 Hz', '50 kV AC, 60 Hz'].each do |voltage_type|
      InfrastructureVoltageType.create!(name: voltage_type, active: true)
    end

    [{name: 'Overhead Contact System', parent: {component_type: 'Contact System'}, active: true},
     {name: 'Third Rail', parent: {component_type: 'Contact System'}, active: true},
     {name: 'Other Contact System', parent: {component_type: 'Contact System'}, active: true},

     {name: 'Bridge', parent: {component_type: 'Structure'}, active: true},
     {name: 'Cantilever Arm', parent: {component_type: 'Structure'}, active: true},
     {name: 'Cantilever Brackets', parent: {component_type: 'Structure'}, active: true},
     {name: 'Foundation', parent: {component_type: 'Structure'}, active: true},
     {name: 'Insulator', parent: {component_type: 'Structure'}, active: true},
     {name: 'Mast', parent: {component_type: 'Structure'}, active: true},
     {name: 'Registration Arm', parent: {component_type: 'Structure'}, active: true},
     {name: 'Registration Tube', parent: {component_type: 'Structure'}, active: true},
     {name: 'Steady Arm', parent: {component_type: 'Structure'}, active: true},].each do |component_subtype|
      component_type = ComponentType.find_by(name: component_subtype[:parent][:component_type])
      ComponentSubtype.create!(component_subtype.except(:parent).merge(parent: component_type))
    end
  end
end