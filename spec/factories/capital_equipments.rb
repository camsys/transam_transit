FactoryBot.define do
  factory :capital_equipment do
    sequence(:asset_tag) { |n| "CAPEQTAG#{n}" }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    policy_replacement_year { Date.today.year + 20 }

    asset_subtype_id { AssetSubtype.find_by(name: "Bus Maintenance Equipment").id }

    # CapitalEquipment is a direct Ruby subclass of TransitAsset (no acts_as/actable, no
    # separate table, no `type` discriminator -- see app/models/capital_equipment.rb). Its
    # default_scope filters on this exact fta_asset_class, so unlike the other four classes
    # here, getting this one wrong wouldn't just fail a validation -- rows would silently be
    # unreachable through the CapitalEquipment class afterwards.
    fta_asset_class { FtaAssetClass.find_by(code: "capital_equipment") }
    fta_asset_category { fta_asset_class.fta_asset_category }
    fta_type_type { "FtaEquipmentType" }
    fta_type_id { FtaEquipmentType.find_by(fta_asset_class_id: fta_asset_class.id, name: "Maintenance Equipment").id }

    manufacture_year { 2001 }
    quantity { 1 }
    quantity_unit { "each" }
    description { "Test Capital Equipment" }

    # CapitalEquipment validates other_manufacturer/other_manufacturer_model presence
    # unconditionally, but deliberately does NOT set manufacturer_id/manufacturer_model_id:
    # TransitAsset's own validation only allows a real manufacturer_id/manufacturer_model_id
    # to coexist with an other_manufacturer/other_manufacturer_model value when that id points
    # at the seeded "Other" row (code "ZZZ" / name "Other"). Leaving the FK attributes unset
    # sidesteps that inclusion check entirely rather than resolving a lookup that would only
    # exist to satisfy a validation this class doesn't otherwise need.
    other_manufacturer { "Test Manufacturer" }
    other_manufacturer_model { "Test Model" }
  end
end
