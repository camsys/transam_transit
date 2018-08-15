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

  def get_default_table_headers()
    ["Asset ID", "Organization", "Description", "Manufacturer", "Model", "Year", "Class", "Type", "Status", "ESL",
     "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def get_all_table_headers()
    ["Asset ID", "Organization", "Description", "Manufacturer", "Model", "Year", "Class", "Type", "Status", "ESL",
     "Last Life Cycle Action", "Life Cycle Action Date", "External ID", "Subtype", "Quantity", "Quantity Type",
     "Funding Program (largest %)", "Direct Capital Responsibility", "Capital Responsibility %", "Asset Group",
     "Service Life - Current", "TERM Condition", "TERM Rating", "Date of Condition Assessment", "Replace / Rehab Policy (ESL",
     "ESL - Adjusted", "Rebuild / Rehab Type", "Date of Rebuild / Rehab", "Location", "Current Book Value",
     "Replacement Status", "Replacement Policy Year", "Replacement Actual Year", "Scheduled Replacement Cost"]
  end

end
