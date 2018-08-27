class FacilityPrimaryAssetTableView  < ActiveRecord::Base

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :facility
  belongs_to :most_recent_asset_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :condition_event, class_name: 'ConditionUpdateEvent', :foreign_key => :condition_event_id
  belongs_to :service_status_event, class_name: 'ServiceStatusUpdateEvent', :foreign_key => :service_status_event_id
  belongs_to :rebuild_event, class_name: 'RehabilitationUpdateEvent', :foreign_key => :rebuild_event_id
  belongs_to :mileage_event, class_name: 'MileageUpdateEvent', :foreign_key => :mileage_event_id
  belongs_to :early_replacement_status_event, class_name: 'ReplacementStatusUpdateEvent', :foreign_key => :early_replacement_status_event_id

  def self.get_default_table_headers
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization*", "Component - Sub-Component Type*",
     "Year", "Class", "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def self.get_all_table_headers
    ["Asset ID", "Organization", "Facility Name", "Facility Categorization*", "Component - Sub-Component Type*",
     "Year", "Class", "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date",
     "External ID", "Subtype*", "Funding Program (largest%)", "Direct Capital Responsibility", "Description*",
     "Asset Group", "Service Life - Current", "TERM Condition", "TERM Rating", "Date of Condition Assessment",
     "Replace / Rehab Policy (ESL)", "ESL - Adjusted", "Rebuild / Rehab Type", "Date of Rebuild / Rehab",
     "Location", "Current Book Value", "Replacement Status", "Replacement Policy Year",
     "Replacement Actual Year", "Scheduled Replacement Cost"]
  end
end