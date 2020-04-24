class RenameComponentElementSubtypes < ActiveRecord::Migration[5.2]
  def change
    rename_table :component_element_types, :new_component_subtypes
    rename_column :component_materials, :component_element_type_id, :new_component_subtype_id
    rename_column :transit_components, :component_element_type_id, :new_component_subtype_id

  end
end
