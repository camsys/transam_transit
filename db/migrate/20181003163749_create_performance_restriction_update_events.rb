class CreatePerformanceRestrictionUpdateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :performance_restriction_types do |t|
      t.string :name
      t.string :description
      t.boolean :active
    end

    add_column :asset_events, :speed_restriction, :decimal, precision: 10, scale: 5, after: :sales_proceeds
    add_column :asset_events, :speed_restriction_unit, :string, after: :speed_restriction
    add_column :asset_events, :period_length, :integer, after: :speed_restriction_unit
    add_column :asset_events, :period_length_unit, :string, after: :period_length

    add_column :asset_events, :from_line, :string, after: :period_length_unit
    add_column :asset_events, :to_line, :string, after: :from_line
    add_column :asset_events, :from_segment, :decimal, precision: 7, scale: 2, after: :to_line
    add_column :asset_events, :to_segment, :decimal, precision: 7, scale: 2, after: :from_segment
    add_column :asset_events, :segment_unit, :string, after: :to_segment
    add_column :asset_events, :from_location_name, :string, after: :segment_unit
    add_column :asset_events, :to_location_name, :string, after: :from_location_name
    add_reference :asset_events, :infrastructure_chain_type, after: :to_location_name
    add_column :asset_events, :relative_location, :decimal, precision: 10, scale: 5, after: :infrastructure_chain_type_id
    add_column :asset_events, :relative_location_unit, :string, after: :relative_location
    add_column :asset_events, :relative_location_direction, :string, after: :relative_location_unit

    add_reference :asset_events, :performance_restriction_type, after: :relative_location_direction

    add_column :asset_events, :event_datetime, :datetime, after: :event_date

  end
end
