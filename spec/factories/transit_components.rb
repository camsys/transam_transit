FactoryBot.define do
  factory :transit_component do
    sequence(:asset_tag) { |n| "TCTAG#{n}" }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    policy_replacement_year { Date.today.year + 20 }

    asset_subtype_id { AssetSubtype.find_by(name: "Special Work Asset").id }

    # Like Infrastructure, TransitComponent has no dedicated FtaAssetClass row of its own.
    # This factory ties it to the "track" fta_asset_class (a rail fastener is a plausible
    # track component) purely to satisfy TransitAsset's presence validation -- it is not a
    # claim that "track" is the/a correct classification for every TransitComponent.
    fta_asset_class { FtaAssetClass.find_by(code: "track") }
    fta_asset_category { fta_asset_class.fta_asset_category }
    fta_type_type { "FtaTrackType" }
    fta_type_id { FtaTrackType.find_by(fta_asset_class_id: fta_asset_class.id, name: "Tangent - Revenue Service").id }

    # component_type -> component_subtype -> component_element is a real parent/child chain
    # (component_subtypes.component_type_id, component_elements.parent_type/parent_id), all
    # resolved by name rather than id so the three stay consistent with each other.
    component_type { ComponentType.find_by(name: "Fasteners") }
    component_subtype { ComponentSubtype.find_by(name: "Spikes & Screws", component_type: component_type) }
    component_element { ComponentElement.find_by(name: "Cut Spike", parent_type: "ComponentSubtype", parent_id: component_subtype.id) }
  end
end
