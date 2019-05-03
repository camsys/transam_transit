class AddParkingNtdFacilities < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :ntd_facilities, :parking_measurement
      add_column :ntd_facilities, :parking_measurement, :integer
    end

    # The unit here is either square feet or parking space. This may be an overcomplication will need to check with Jack/Andreas
    unless column_exists? :ntd_facilities, :parking_measurement_unit
      add_column :ntd_facilities, :parking_measurement_unit, :string
    end
  end
end
