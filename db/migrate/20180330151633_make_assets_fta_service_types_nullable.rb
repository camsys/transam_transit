class MakeAssetsFtaServiceTypesNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null :assets_fta_service_types, :asset_id, true
    change_column_null :assets_fta_service_types, :fta_service_type_id, true
  end
end
