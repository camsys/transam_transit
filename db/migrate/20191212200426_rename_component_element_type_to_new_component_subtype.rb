class RenameComponentElementTypeToNewComponentSubtype < ActiveRecord::Migration[5.2]
  def change
    rename_table :component_element_types, :new_component_subtypes
  end
end
