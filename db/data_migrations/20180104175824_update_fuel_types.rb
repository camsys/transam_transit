class UpdateFuelTypes < ActiveRecord::DataMigration
  def up
    FuelType.find_by(code: 'EP').update!(name: 'Electric Propulsion Power')
    FuelType.find_by(code: 'HY').update!(name: 'Hydrogen Cell')
    FuelType.create!({:active => 0, :name => 'Used/Recycled Cooking Oil',      :code => 'CK', :description => 'Used/Recycled Cooking Oil.'})
  end
end