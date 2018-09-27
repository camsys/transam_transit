class AddDualFuelTypes < ActiveRecord::DataMigration
  def up
    DualFuelType.delete_all if DualFuelType.count > 0

    dual_fuel_types = [
        {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Compressed Natural Gas'},
        {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Used/Recycled Cooking Oil'},
        {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Electric Propulsion Power'},
        {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Electric Battery'},
        {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Kerosene'},
        {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Liquefied Petroleum Gas'},
        {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Compressed Natural Gas'},
        {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Used/Recycled Cooking Oil'},
        {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Electric Battery'},
        {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Electric Propulsion Power'},
        {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Kerosene'},
        {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Liquefied Petroleum Gas'},
        {active: true, primary_fuel_type: 'Gasoline', secondary_fuel_type: 'Compressed Natural Gas'},
        {active: true, primary_fuel_type: 'Gasoline', secondary_fuel_type: 'Ethanol'},
        {active: true, primary_fuel_type: 'Gasoline', secondary_fuel_type: 'Liquefied Petroleum Gas'},
        {active: true, primary_fuel_type: 'Hybrid Gasoline', secondary_fuel_type: 'Compressed Natural Gas'},
        {active: true, primary_fuel_type: 'Hybrid Gasoline', secondary_fuel_type: 'Ethanol'},
        {active: true, primary_fuel_type: 'Hybrid Gasoline', secondary_fuel_type: 'Liquefied Petroleum Gas'}
    ]

    dual_fuel_types.each do |fuel_type|
      DualFuelType.create!(primary_fuel_type: FuelType.find_by(name: fuel_type[:primary_fuel_type]), secondary_fuel_type: FuelType.find_by(name: fuel_type[:secondary_fuel_type]), active: true)
    end
  end

  def down
    DualFuelType.delete_all
  end
end