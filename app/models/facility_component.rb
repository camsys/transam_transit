class FacilityComponent < TransamAssetRecord
  acts_as :capital_equipment, as: :capital_equipmentible

  belongs_to :facility_component_type
  belongs_to :facility_component_subtype

  FORM_PARAMS = [
      :facility_component_type_id,
      :facility_component_subtype_id
  ]

  CLEANSABLE_FIELDS = [

  ]

  def dup
    super.tap do |new_asset|
      new_asset.capital_equipment = self.capital_equipment.dup
    end
  end

  def get_default_table_headers()
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization", "Component - Sub-Component Type",
     "Year", "Class", "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def get_all_table_headers()
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization", "Component - Sub-Component Type",
     "Year", "Class", "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date", "External ID",
     "Subtype", "Funding Program (largest %)", "Direct Capital Responsibility", "Description", "Asset Group",
     "Service Life - Current", "TERM Condition", "TERM Rating", "Date of Condition Assessment", "Replace / Rehab Policy (ESL)",
     "ESL - Adjusted", "Rebuild / Rehab Type", "Date of Rebuild / Rehab", "Location", "Current Book Value",
     "Replacement Status", "Replacement Policy Year", "Replacement Actual Year", "Scheduled Replacement Cost"]
  end

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method #{method}"
      Rails.logger.warn "You are calling the old asset for this method #{method}"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

end
