class MakeAssetsFtaModeTypesNullable < ActiveRecord::Migration
  def change
    change_column_null :assets_fta_mode_types, :asset_id, true
    change_column_null :assets_fta_mode_types, :fta_mode_type_id, true
  end
end
