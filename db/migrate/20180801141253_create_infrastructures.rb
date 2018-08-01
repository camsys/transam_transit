class CreateInfrastructures < ActiveRecord::Migration[5.2]
  def change

    create_table :infrastructure_segment_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_chain_types do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_divisions do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_subdivisions do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_tracks do |t|
      t.string :name
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

    create_table :infrastructures do |t|
      t.string :from_line
      t.string :to_line
      t.references :infrastructure_segment_type
      t.integer :from_segment
      t.integer :to_segment
      t.string :measurement_unit
      t.string :from_location_name
      t.string :to_location_name
      t.references :infrastructure_chain_type
      t.integer :relative_location
      t.string :relative_location_unit
      t.string :relative_location_direction
      t.references :infrastructure_division
      t.references :infrastructure_subdivision
      t.references :infrastructure_track
      t.string :direction
      t.references :infrastructure_gauge_type
      t.integer :gauge
      t.string :gauge_unit
      t.references :infrastructure_reference_rail
      t.integer :track_gradient_pcnt
      t.integer :track_gradient_degree
      t.integer :track_gradient
      t.string :track_gradient_unit
      t.integer :horizontal_alignment
      t.string :horizontal_alignment_unit
      t.integer :vertical_alignment
      t.string :vertical_alignment_unit
      t.integer :crosslevel
      t.string :crosslevel_unit
      t.integer :warp_parameter
      t.string :warp_parameter_unit
      t.integer :track_curvature
      t.string :track_curvature_unit
      t.integer :track_curvature_degree
      t.integer :cant
      t.string :cant_unit
      t.integer :cant_gradient
      t.string :cant_gradient_unit
      t.integer :full_service_speed
      t.string :full_service_speed_unit
      t.references :land_ownership_organization
      t.string :other_land_ownership_organization
      t.references :shared_capital_responsibility_organization

      t.timestamps
    end

    create_table :infrastructure_rail_joinings do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_tie_forms do |t|
      t.string :name
      t.boolean :active
    end

    create_table :infrastructure_tie_materials do |t|
      t.string :name
      t.boolean :active
    end

    add_reference :components, :infrastructure_rail_joining, after: :component_subtype
    add_reference :components, :infrastructure_tie_form, after: :component_subtype
    add_reference :components, :infrastructure_tie_material, after: :component_subtype

  end
end
