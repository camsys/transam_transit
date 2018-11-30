class RenameComponentToTransitComponent < ActiveRecord::Migration[5.2]
  def change
    rename_table :components, :transit_components
  end
end
