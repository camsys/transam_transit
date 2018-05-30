class AddNewColumnsToBothFacilitiesTables < ActiveRecord::Migration
  def change
    unless column_exists? :ntd_admin_and_maintenance_facilities, :reported_condition_rating
      add_column :ntd_admin_and_maintenance_facilities, :reported_condition_rating, :integer, :null => true
    end
    unless column_exists? :ntd_passenger_and_parking_facilities, :reported_condition_rating
      add_column :ntd_passenger_and_parking_facilities, :reported_condition_rating, :integer, :null => true
    end
    unless column_exists? :ntd_passenger_and_parking_facilities, :parking_measurement
      add_column :ntd_passenger_and_parking_facilities, :parking_measurement, :integer, :null => true
    end
    # The unit here is either square feet or parking space. This may be an overcomplication will need to check with Jack/Andreas
    unless column_exists? :ntd_passenger_and_parking_facilities, :parking_measurement_unit
      add_column :ntd_passenger_and_parking_facilities, :parking_measurement_unit, :integer, :null => true
    end
    unless column_exists? :ntd_admin_and_maintenance_facilities, :facility_object_key
      add_column :ntd_admin_and_maintenance_facilities, :facility_object_key, :integer, :null => true
    end
    unless column_exists? :ntd_passenger_and_parking_facilities, :facility_object_key
      add_column :ntd_passenger_and_parking_facilities, :facility_object_key, :integer, :null => true
    end
  end
end

