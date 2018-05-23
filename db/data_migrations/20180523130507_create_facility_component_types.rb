class CreateFacilityComponentTypes < ActiveRecord::DataMigration
  def up
    facility_component_types= [
        {name: 'Substructure', active: true},
        {name: 'Shell', active: true},
        {name: 'Interior', active: true},
        {name: 'Conveyance', active: true},
        {name: 'Plumbing', active: true},
        {name: 'HVAC', active: true},
        {name: 'Fire Protection', active: true},
        {name: 'Electrical', active: true},
        {name: 'Equipment / Fare Collection', active: true},
        {name: 'Site', active: true}
    ]

    facility_component_types.each do |type|
      FacilityComponentType.create!(type)
    end
  end
end