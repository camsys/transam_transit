class RevenueVehicleAssetTableView  < ActiveRecord::Base

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :revenue_vehicle
  belongs_to :asset_group, class_name: 'AssetGroup', :foreign_key => :asset_group_id
  belongs_to :asset_fleet, class_name: 'AssetFleet', :foreign_key => :asset_fleet_id

  belongs_to :condition_event, class_name: 'ConditionUpdateEvent', :foreign_key => :condition_event_id
  belongs_to :maintenance_event, class_name: 'MaintenanceUpdateEvent', :foreign_key => :maintenance_event_id
  belongs_to :service_status_event, class_name: 'ServiceStatusUpdateEvent', :foreign_key => :service_status_event_id
  belongs_to :location_event, class_name: 'LocationUpdateEvent', :foreign_key => :location_event_id
  belongs_to :rebuild_event, class_name: 'RehabilitationUpdateEvent', :foreign_key => :rebuild_event_id
  belongs_to :disposition_event, class_name: 'DispositionUpdateEvent', :foreign_key => :disposition_event_id
  belongs_to :mileage_event, class_name: 'MileageUpdateEvent', :foreign_key => :mileage_event_id
  belongs_to :operation_event, class_name: 'OperationsUpdateEvent', :foreign_key => :operation_event_id
  belongs_to :facility_operation_event, class_name: 'FacilitOperationsUpdateEvent', :foreign_key => :facility_operation_event_id
  belongs_to :vehicle_use_event, class_name: 'VehicleUsageUpdateEvent', :foreign_key => :vehicle_use_event_id
  belongs_to :storage_event, class_name: 'StorageMethodUpdateEvent', :foreign_key => :storage_event_id
  belongs_to :useage_event, class_name: 'AssetEvent', :foreign_key => :useage_event_id
  belongs_to :maintenace_history_event, class_name: 'MaintenanceUpdateEvent', :foreign_key => :maintenace_history_event_id
  belongs_to :early_disposition_event, class_name: 'EarlyDispositionRequestUpdateEvent', :foreign_key => :early_disposition_event_id
  belongs_to :early_replacement_status_event, class_name: 'ReplacementStatusUpdateEvent', :foreign_key => :early_replacement_status_event_id



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
    unless condition_event.nil?
      event_list << condition_event
    end

    unless maintenance_event.nil?
      event_list << maintenance_event
    end

    unless service_status_event.nil?
      event_list << service_status_event
    end

    unless location_event.nil?
      event_list << location_event
    end

    unless rebuild_event.nil?
      event_list << rebuild_event
    end

    unless disposition_event.nil?
      event_list << disposition_event
    end

    unless mileage_event.nil?
      event_list << mileage_event
    end

    unless operation_event.nil?
      event_list << operation_event
    end

    unless facility_operation_event.nil?
      event_list << facility_operation_event
    end

    unless vehicle_use_event.nil?
      event_list << vehicle_use_event
    end

    unless storage_event.nil?
      event_list << storage_event
    end

    unless useage_event.nil?
      event_list << useage_event
    end

    unless maintenace_history_event.nil?
      event_list << maintenace_history_event
    end

    unless early_disposition_event.nil?
      event_list << early_disposition_event
    end

    unless early_replacement_status_event.nil?
      event_list << early_replacement_status_event
    end

    event_list.sort_by{|event| event[:updated_at]}.first

  end

end