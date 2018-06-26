FactoryBot.define do

  factory :policy_asset_subtype_rule do
    asset_subtype_id 1
    min_service_life_months 144
    min_service_life_miles 500000
    replacement_cost 395500
    cost_fy_year 6
    replace_with_new true
    replace_with_leased false
    rehabilitation_code 'XXXXXXXX'
    purchase_replacement_code 'XXXXXXXX'
    default_rule true
  end
end
