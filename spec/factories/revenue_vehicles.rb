FactoryBot.define do
  factory :revenue_vehicle do

    serial_number { "VINNY1234" }
    asset_tag { "TAGGY1234" }
    asset_subtype_id { 1 }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    fta_asset_category { FtaAssetCategory.first }
    fta_asset_class { FtaAssetClass.find_by(code: "bus") }
    fta_type_id { 10 }
    fta_type_type { "FtaVehicleType" }
    manufacture_year { 2001 }
    manufacturer_id { 1 }
    manufacturer_model_id { 1 }
    fuel_type_id { 1 }
    vehicle_length { 40 }
    vehicle_length_unit { "feet" }
    seating_capacity { 50 }
    standing_capacity { 100 }
    ada_accessible { true }
    esl_category_id { 1 }
    fta_funding_type { FtaFundingType.first }
    fta_ownership_type { FtaOwnershipType.first }

  end
end
