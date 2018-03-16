class AddDefaultUsefulLifeBenchmarks < ActiveRecord::DataMigration
  def up
    [
        ['AB', 14],
        ['AG',	31],
        ['AO',	8],
        ['BR',	14],
        ['BU',	14],
        ['CC',	112],
        ['CU',	10],
        ['DB',	14],
        ['FB',	42],
        ['HR',	31],
        ['IP',	56],
        ['LR',	31],
        ['MB',	10],
        ['MO',	31],
        ['MV',	8],
        ['RL',	39],
        ['RP',	39],
        ['RS',	39],
        ['RT',	14],
        ['SB',	14],
        ['SR',	31],
        ['SV',	8],
        ['TB',	13],
        ['TR',	12],
        ['VN',	8],
        ['VT',	58]
    ].each do |vehicle_type|
      FtaVehicleType.find_by(code: vehicle_type[0]).update!(default_useful_life_benchmark: vehicle_type[1], useful_life_benchmark_unit: 'year')
    end


    [
        ['Automobiles',	8],
        ['Trucks and Other Rubber Tire Vehicles',	14],
        ['Steel Wheel Vehicles',	25]
    ].each do |support_vehicle_type|
      FtaSupportVehicleType.find_by(name: support_vehicle_type[0]).update!(default_useful_life_benchmark: support_vehicle_type[1], useful_life_benchmark_unit: 'year')
    end
  end

  def down
    FtaVehicleType.update_all(default_useful_life_benchmark: nil, useful_life_benchmark_unit: nil)
    FtaSupportVehicleType.update_all(default_useful_life_benchmark: nil, useful_life_benchmark_unit: nil)
  end
end