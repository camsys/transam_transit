class CreateRevenueVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :revenue_vehicles do |t|
      t.references :esl_category
      t.integer :standing_capacity
      t.references :fta_funding_type
      t.references :fta_ownership_type
      t.string :other_fta_ownership_type
      t.boolean :dedicated

      t.timestamps
    end
  end
end
