class RenameComponentElementSubtypesStepTwo < ActiveRecord::Migration[5.2]
  def change
    rename_table :component_subtypes, :component_elements
    rename_column :transit_components, :component_subtype_id, :component_element_id

    rename_table :new_component_subtypes, :component_subtypes
    rename_column :component_materials, :new_component_subtype_id, :component_subtype_id
    rename_column :transit_components, :new_component_subtype_id, :component_subtype_id



  end
end
