class AddFtaFieldsPolicyRules < ActiveRecord::Migration[4.2]
  def change
    add_column :policy_asset_subtype_rules, :fta_useful_life_benchmark, :integer, after: :construction_code
    add_reference :policy_asset_subtype_rules, :fta_vehicle_type, after: :fta_useful_life_benchmark
    add_reference :policy_asset_subtype_rules, :fta_facility_type, after: :fta_vehicle_type_id
  end
end