FactoryBot.define do
  factory :service_vehicle do
    sequence(:asset_tag) { |n| "SVCTAG#{n}" }
    sequence(:serial_number) { |n| "SVCSERIAL#{n}" }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    policy_replacement_year { Date.today.year + 20 }

    # Legacy asset_subtype_id, still required at the TransamAsset level. Resolved by name
    # (not a bare id) against the seeded row that best matches a non-revenue service vehicle.
    asset_subtype_id { AssetSubtype.find_by(name: "Tow Truck").id }

    # fta_asset_class is resolved by its stable `code`; category and type are derived from it
    # rather than picked independently, so they can't drift out of sync with each other.
    fta_asset_class { FtaAssetClass.find_by(code: "service_vehicle") }
    fta_asset_category { fta_asset_class.fta_asset_category }
    fta_type_type { "FtaSupportVehicleType" }
    fta_type_id { FtaSupportVehicleType.find_by(fta_asset_class_id: fta_asset_class.id, name: "Trucks and other Rubber Tire Vehicles").id }

    # ServiceVehicle's own required associations/attributes.
    manufacture_year { 2001 }
    manufacturer_id { Manufacturer.find_by(code: "FRD", filter: "SupportVehicle").id }
    manufacturer_model_id { ManufacturerModel.find_by(name: "Other").id }
    fuel_type_id { FuelType.find_by(code: "DF").id }
    vehicle_length { 20 }
    vehicle_length_unit { "feet" }
    seating_capacity { 2 }
    ada_accessible { true }

    # NOTE: fta_asset_class code "service_vehicle" has name "Service Vehicles (Non-Revenue)",
    # not "Buses (Rubber Tire Vehicles)", so ServiceVehicle#serial_number_required? is false
    # here and the VIN length/format validation never engages. The sequence above only needs
    # to satisfy #serial_number_unique_with_exceptions (uniqueness), not VIN shape.
  end
end
