class CreateTamPolicies < ActiveRecord::Migration[4.2]
  def change
    create_table :tam_policies do |t|
      t.string :object_key
      t.integer :fy_year
      t.boolean :copied
      t.timestamps null: false
    end

    create_table :tam_groups do |t|
      t.string :object_key
      t.references :organization, index: true
      t.references :tam_policy, index: true
      t.string :name
      t.integer :leader_id
      t.integer :parent_id
      t.string :state

      t.timestamps null: false
    end

    create_table :tam_groups_organizations, id: false do |t|
      t.belongs_to :tam_group
      t.belongs_to :organization
    end

    create_table :tam_performance_metrics do |t|
      t.string :object_key
      t.references :tam_group, index: true
      t.integer :parent_id
      t.integer :useful_life_benchmark
      t.string :useful_life_benchmark_unit
      t.boolean :useful_life_benchmark_locked
      t.integer :pcnt_goal
      t.boolean :pcnt_goal_locked

      t.timestamps null: false
    end
  end
end
