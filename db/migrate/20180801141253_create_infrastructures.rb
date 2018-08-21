class CreateInfrastructures < ActiveRecord::Migration[5.2]
  def change

    # FTA types
    create_table :fta_track_types do |t|
      t.string :name
      t.boolean :active
    end
    create_table :fta_guideway_types do |t|
      t.string :name
      t.boolean :active
    end
    create_table :fta_power_signal_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_segment_unit_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_chain_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_segment_types do |t|
      t.references :fta_asset_class
      t.references :asset_subtype
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_divisions do |t|
      t.string :name
      t.references :organization
      t.boolean :active
    end

    create_table :infrastructure_subdivisions do |t|
      t.string :name
      t.references :organization
      t.boolean :active
    end

    create_table :infrastructure_tracks do |t|
      t.string :name
      t.references :organization
      t.boolean :active
    end

    create_table :infrastructure_gauge_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_reference_rails do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_bridge_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_crossings do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_operation_method_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_control_system_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructures do |t|
      t.string :from_line
      t.string :to_line
      t.references :infrastructure_segment_unit_type
      t.decimal :from_segment
      t.decimal :to_segment
      t.string :segment_unit
      t.string :from_location_name
      t.string :to_location_name
      t.references :infrastructure_chain_type
      t.decimal :relative_location
      t.string :relative_location_unit
      t.string :relative_location_direction
      t.string :location_name
      t.references :infrastructure_segment_type
      t.references :infrastructure_division
      t.references :infrastructure_subdivision
      t.references :infrastructure_track
      t.integer :num_tracks
      t.string :direction
      t.references :infrastructure_operation_method_type
      t.references :infrastructure_control_system_type
      t.references :infrastructure_bridge_type
      t.integer :num_spans
      t.integer :num_decks
      t.references :infrastructure_crossing
      t.references :infrastructure_gauge_type
      t.decimal :gauge
      t.string :gauge_unit
      t.references :infrastructure_reference_rail
      t.decimal :track_gradient_pcnt
      t.decimal :track_gradient_degree
      t.decimal :track_gradient
      t.string :track_gradient_unit
      t.decimal :horizontal_alignment
      t.string :horizontal_alignment_unit
      t.decimal :vertical_alignment
      t.string :vertical_alignment_unit
      t.decimal :length
      t.string :length_unit
      t.decimal :height
      t.string :height_unit
      t.decimal :width
      t.string :width_unit
      t.decimal :crosslevel
      t.string :crosslevel_unit
      t.decimal :warp_parameter
      t.string :warp_parameter_unit
      t.decimal :track_curvature
      t.string :track_curvature_unit
      t.decimal :track_curvature_degree
      t.decimal :cant
      t.string :cant_unit
      t.decimal :cant_gradient
      t.string :cant_gradient_unit
      t.decimal :max_permissible_speed
      t.string :max_permissible_speed_unit
      t.references :land_ownership_organization
      t.string :other_land_ownership_organization
      t.references :shared_capital_responsibility_organization, index: {name: :shared_cap_responsibility_org_infrastructure_idx}
      t.string :nearest_city
      t.string :nearest_state

      t.timestamps
    end

    create_table :infrastructure_rail_joinings do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_cap_materials do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_foundations do |t|
      t.string :name
      t.boolean :active
    end

    create_table :component_materials do |t|
      t.string :name
      t.references :component_type
      t.references :component_element_type
      t.boolean :active
    end

    add_reference :components, :component_material, after: :component_subtype_id
    add_reference :components, :infrastructure_rail_joining, after: :component_material_id
    add_reference :components, :infrastructure_cap_material, after: :infrastructure_rail_joining_id
    add_reference :components, :infrastructure_foundation, after: :infrastructure_cap_material_id
    add_column :components, :infrastructure_measurement, :integer, after: :infrastructure_rail_joining_id
    add_column :components, :infrastructure_measurement_unit, :string, after: :infrastructure_measurement
    add_column :components, :infrastructure_weight, :integer, after: :infrastructure_measurement_unit
    add_column :components, :infrastructure_weight_unit, :string, after: :infrastructure_weight
  end
end
