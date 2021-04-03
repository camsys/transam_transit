FactoryBot.define do
  factory :transit_asset do
    asset_tag { "TAGGY1234" }
    asset_subtype_id { 1 }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    policy_replacement_year { Date.today.year + 20 }
    fta_asset_category { FtaAssetCategory.first }
    fta_asset_class { FtaAssetClass.find_by(code: "bus") }
    fta_type_id { 10 }
    fta_type_type { "FtaVehicleType" }

  end
end

