class CreateRampManufacturers < ActiveRecord::Migration[5.2]
  def change
    create_table :ramp_manufacturers do |t|
      t.string :name
      t.boolean :active
    end
  end
end
