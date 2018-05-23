class CreateFacilityComponentCategorizations < ActiveRecord::DataMigration
  def up
    facility_component_categorizations = [
        {name: 'Component (of Primary Facility)', active: true},
        {name: 'Sub-Component (of Primary Facility)', active: true}
    ]

    facility_component_categorizations.each do |categorization|
      FacilityComponentCategorization.create!(categorization)
    end
  end
end