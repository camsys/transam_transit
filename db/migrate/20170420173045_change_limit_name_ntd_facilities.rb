class ChangeLimitNameNtdFacilities < ActiveRecord::Migration[4.2]
  def change
    change_column :ntd_admin_and_maintenance_facilities, :name, :string, :limit => 128
    change_column :ntd_passenger_and_parking_facilities, :name, :string, :limit => 128
  end
end
