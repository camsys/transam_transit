class AddCreatorAssetFleets < ActiveRecord::Migration
  def change
    add_column :asset_fleets, :created_by_user_id, :integer, after: :active
  end
end
