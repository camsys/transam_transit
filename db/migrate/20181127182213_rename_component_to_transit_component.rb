class RenameComponentToTransitComponent < ActiveRecord::Migration[5.2]
  def change
    rename_table :components, :transit_components

    TransitAsset.where(transit_assetible_type: 'Component').update_all('TransitComponent')
  end
end
