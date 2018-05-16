class ChangeFacilityObjectKey < ActiveRecord::Migration
  def change
    if column_exists? :ntd_admin_and_maintenance_facilities, :facility_object_key
      change_column :ntd_admin_and_maintenance_facilities, :facility_object_key, :string, :limit => 12
    end
    if column_exists? :ntd_passenger_and_parking_facilities, :facility_object_key
      change_column :ntd_passenger_and_parking_facilities, :facility_object_key, :string, :limit => 12
    end
  end
end
