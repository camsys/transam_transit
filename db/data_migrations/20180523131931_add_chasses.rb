class AddChasses < ActiveRecord::DataMigration
  def up
    chasses = [
        {name: 'Chevrolet Express 3500', active: true},
        {name: 'Chevrolet Express 4500', active: true},
        {name: 'Chevrolet G3500', active: true},
        {name: 'Chevrolet G4500', active: true},
        {name: 'Ford F-350', active: true},
        {name: 'Ford F-450', active: true},
        {name: 'Ford F-550', active: true},
        {name: 'Ford F-650', active: true},
        {name: 'Ford F-750', active: true},
        {name: 'Ford Transit', active: true},
        {name: 'Freightliner M2', active: true},
        {name: 'Freightliner MB55', active: true},
        {name: 'Freightliner MB65', active: true},
        {name: 'Freightliner MB75', active: true},
        {name: 'International UC', active: true},
        {name: 'International 3200', active: true},
        {name: 'International 3300', active: true},
        {name: 'Monocoque', active: true},
        {name: 'Other', active: true}
    ]

    chasses.each do |chassis|
      Chassis.create!(chassis)
    end
  end
end