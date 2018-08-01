class CapitalEquipment < TransitAsset
  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :quantity, presence: true
  validates :quantity_unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }

end
