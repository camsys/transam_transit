FactoryGirl.define do

  trait :basic_policy_attributes do
    association :organization, :factory => :organization
    interest_rate "0.05"
    service_life_calculation_type_id 1
    cost_calculation_type_id 1
    condition_estimation_type_id 1
    depreciation_calculation_type_id 1
    condition_threshold 2.5
    name 'TestPolicy'
    description 'Test Policy'
    year Date.today.year
    current true
    active true
  end

  factory :policy do
    basic_policy_attributes
  end

  factory :parent_policy, :class => :policy do
    basic_policy_attributes

    after(:create) do |policy|
      AssetType.all.each do |type|
        create(:policy_asset_type_rule, policy: policy, asset_type: type)
      end
      AssetSubtype.all.each do |subtype|
        create(:policy_asset_subtype_rule, policy: policy, asset_subtype: subtype)
      end
    end
  end
end
