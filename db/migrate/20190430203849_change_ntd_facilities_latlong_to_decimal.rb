class ChangeNtdFacilitiesLatlongToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :ntd_facilities, :longitude, :decimal, precision: 11, scale: 6
    change_column :ntd_facilities, :latitude, :decimal, precision: 11, scale: 6
  end
end
