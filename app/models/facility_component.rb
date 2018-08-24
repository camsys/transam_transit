class FacilityComponent < Component

  def get_default_table_headers()
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization", "Component - Sub-Component Type",
     "Year", "Class", "Type", "Status", "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def get_all_table_headers()
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization", "Component - Sub-Component Type",
     "Year", "Class", "Type", "Status", "Last Life Cycle Action", "Life Cycle Action Date", "External ID",
     "Subtype", "Funding Program (largest %)", "Direct Capital Responsibility", "Description", "Asset Group",
     "Service Life - Current", "TERM Condition", "TERM Rating", "Date of Condition Assessment",
     "Rebuild / Rehab Type", "Date of Rebuild / Rehab", "Location", "Current Book Value",
     "Replacement Status", "Replacement Policy Year", "Replacement Actual Year", "Scheduled Replacement Cost"]
  end

end
