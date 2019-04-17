class RemoveDuplicateLengthQueryField < ActiveRecord::Migration[5.2]
  def change
    QueryField.where(name: 'infrastructure_measurement').destroy_all
    QueryField.where(name: 'infrastructure_measurement_unit').destroy_all

    qf = QueryField.find_by_name('culverts_measurement')
    qf.update(label: 'Length (Infra. Component)') if qf

    qf = QueryField.find_by_name('vehicle_length')
    qf.update(label: 'Length (Vehicles)') if qf
  end
end
