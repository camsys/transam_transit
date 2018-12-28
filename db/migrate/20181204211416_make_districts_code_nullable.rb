class MakeDistrictsCodeNullable < ActiveRecord::Migration[5.2]
  def change
    change_column :districts, :code, :string, null: true
  end
end
