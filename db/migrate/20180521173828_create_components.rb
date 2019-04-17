class CreateComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :component_types do |t|
      t.references :fta_asset_category
      t.references :fta_asset_class
      t.string :name
      t.string :class_name
      t.boolean :active
    end

    create_table :component_element_types do |t|
      t.string :name
      t.references :component_type
      t.boolean :active
    end

    create_table :component_subtypes do |t|
      t.references :parent, polymorphic: true
      t.string :name
      t.boolean :active
    end


    create_table :components do |t|
      t.references :component_type
      t.references :component_element_type
      t.references :component_subtype

      t.timestamps
    end


  end
end
