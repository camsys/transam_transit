class CapitalEquipment < TransitAsset
  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :quantity, presence: true
  validates :quantity_unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :manufacturer_id, presence: true
  validates :manufacturer_model_id, presence: true

end
