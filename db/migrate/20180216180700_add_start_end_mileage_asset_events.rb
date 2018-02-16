class AddStartEndMileageAssetEvents < ActiveRecord::Migration
  def change
    add_column :asset_events, :mileage_start, :integer, after: :condition_type_id
    add_column :asset_events, :mileage_start_date, :date, after: :event_date
  end
end
