class AddAppraisalFieldsToAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :assessed_value, :integer
  end
end
