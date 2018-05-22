class FacilityComponent < ApplicationRecord
  acts_as :capital_equipment, as: :capital_equipmentible

  belongs_to :facility_categorization
  belongs_to :component_type
end
