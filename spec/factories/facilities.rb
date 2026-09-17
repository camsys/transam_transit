FactoryBot.define do
  factory :facility do
    sequence(:asset_tag) { |n| "FACTAG#{n}" }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    policy_replacement_year { Date.today.year + 20 }

    asset_subtype_id { AssetSubtype.find_by(name: "Administration Building").id }

    fta_asset_class { FtaAssetClass.find_by(code: "admin_facility") }
    fta_asset_category { fta_asset_class.fta_asset_category }
    fta_type_type { "FtaFacilityType" }
    fta_type_id { FtaFacilityType.find_by(fta_asset_class_id: fta_asset_class.id, name: "Administrative Office / Sales Office").id }

    manufacture_year { 2001 }
    facility_name { "Test Facility" }
    address1 { "5000 Forbes Ave" }
    city { "Pittsburgh" }
    state { "PA" }
    zip { "15213" }
    country { "USA" }
    esl_category_id { EslCategory.find_by(name: "Facilities").id }
    facility_size { 10000 }
    facility_size_unit { "sq ft" }
    section_of_larger_facility { false }
    ada_accessible { true }
  end
end
