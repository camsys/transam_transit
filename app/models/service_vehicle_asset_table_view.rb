class ServiceVehicleAssetTableView  < ActiveRecord::Base

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :service_vehicle
  belongs_to :condition_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :maintenance_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :service_status_event, class_name: 'ServiceStatusUpdateEvent', :foreign_key => :id
  belongs_to :location_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :rebuild_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :disposition_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :mileage_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :operation_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :facility_operation_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :vehicle_use_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :storage_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :useage_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :maintenace_history_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :early_disposition_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :early_replacement_status_event, class_name: 'AssetEvent', :foreign_key => :id


  def self.get_default_table_headers()
    ["Asset ID", "Organization", "VIN", "Manufacturer", "Model", "Year", "Class",
     "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def self.get_all_table_headers()
    ["Asset ID", "Organization", "VIN", "Manufacturer", "Model", "Year", "Class", "Type", "Status", "ESL",
     "Last Life Cycle Action", "Life Cycle Action Date", "External ID", "Subtype", "ESL Category", "Chassis",
     "Fuel Type", "Funding Program (largest %)", "Operator", "Plate #", "Primary Mode", "Direct Capital Responsibility",
     "Capital Responsibility %", "Asset Group", "Service Life - Current", "TERM Condition", "TERM Rating", "NTD ID",
     "Date of Condition Assessment", "Odometer Reading", "Date of Odometer Reading", "Replace / Rehab Policy (ESL)",
     "TAM Policy (ULB)", "ESL - Adjusted", "ULB - Adjusted", "Rebuild / Rehab Type", "Date of Rebuild / Rehab", "Location",
     "Current Book Value", "Replacement Status", "Replacement Policy Year", "Replacement Actual Year", "Scheduled Replacement Cost"]
  end

  def get_most_recent_event

    event_list = []
    event_list << condition_event
    event_list << maintenance_event
    event_list << service_status_event
    event_list << location_event
    event_list << rebuild_event
    event_list << disposition_event
    event_list << mileage_event
    event_list << operation_event
    event_list << facility_operation_event
    event_list << vehicle_use_event
    event_list << storage_event
    event_list << useage_event
    event_list << maintenace_history_event
    event_list << early_disposition_event
    event_list << early_replacement_status_event

    event_list.sort_by{|event| event[:updated_at]}.first

  end

end