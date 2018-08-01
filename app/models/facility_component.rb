class FacilityComponent < Component
  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :facility_component_type_id, presence: true
  validates :facility_component_subtype_id, presence: true
  validates :num_structures, numericality: { greater_than_or_equal_to: 0 }
  validates :num_floors, numericality: { greater_than_or_equal_to: 0 }
  validates :num_elevators, numericality: { greater_than_or_equal_to: 0 }
  validates :num_escalators, numericality: { greater_than_or_equal_to: 0 }
  validates :num_public_parking, numericality: { greater_than_or_equal_to: 0 }
  validates :num_private_parking, numericality: { greater_than_or_equal_to: 0 }
  validates :lot_size, numericality: { greater_than: 0 }
  validates :lot_size_unit, presence: true, if: :gross_vehicle_weight


end
