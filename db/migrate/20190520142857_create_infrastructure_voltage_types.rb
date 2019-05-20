class CreateInfrastructureVoltageTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :infrastructure_voltage_types do |t|
      t.name :string
      t.boolean :active
    end

    add_reference :infrastructure_components, :infrastructure_voltage_type
  end
end
