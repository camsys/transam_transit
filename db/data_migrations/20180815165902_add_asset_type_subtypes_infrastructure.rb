class AddAssetTypeSubtypesInfrastructure < ActiveRecord::DataMigration
  def up
    infrastructure_asset_type = AssetType.create!({
        name: "Infrastructure",
        class_name: "TransamAsset",
        display_icon_name: "fa fa-road",
        map_icon_name: 'blueIcon',
        description: "Infrastructure placeholder asset type",
        allow_parent: false,
        active: true
    })

    asset_subtypes = [
      'Tangent (Straight)',
      'Curve',
      'Transition Curve',
      'Special Work Asset',
      'At-Grade',
      'Bridge',
      'Tunnel',
      'Signal Equipment',
      'Signal System'
    ]

    asset_subtypes.each do |subtype|
      infrastructure_asset_type.asset_subtypes.create!(name: subtype, description: subtype, active: true)
    end
  end
end