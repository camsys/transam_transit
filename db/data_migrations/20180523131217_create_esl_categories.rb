class CreateEslCategories < ActiveRecord::DataMigration
  def up
    esl_categories = [
        {name: 'Heavy-Duty Large Bus', class_name: 'RevenueVehicle', active: true},
        {name: 'Heavy-Duty Small Bus', class_name: 'RevenueVehicle', active: true},
        {name: 'Medium-Duty and Purpose-Built Bus', class_name: 'RevenueVehicle', active: true},
        {name: 'Light Duty Mid-Sized Bus', class_name: 'RevenueVehicle', active: true},
        {name: 'Light Duty Small Bus, Cutaways, and Modified Van', class_name: 'RevenueVehicle', active: true},
        {name: 'Electric Trolley-Bus', class_name: 'RevenueVehicle', active: true},
        {name: 'Steel-Wheel Trolley', class_name: 'RevenueVehicle', active: true},
        {name: 'Ferry', class_name: 'RevenueVehicle', active: true},
        {name: 'Rail Vehicle', class_name: 'RevenueVehicle', active: true},
        {name: 'Facilities', class_name: 'Facility', active: true},
    ]

    esl_categories.each do |category|
      EslCategory.create!(category)
    end
  end
end