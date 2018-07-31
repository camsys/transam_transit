class AddFacilityComponentSubtypeFacilityComponents < ActiveRecord::Migration[5.2]
  def change
    add_reference :facility_components, :facility_component_subtype
  end
end
