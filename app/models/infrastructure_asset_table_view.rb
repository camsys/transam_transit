class InfrastructureAssetTableView < ActiveRecord::Base

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :infrastructure
  belongs_to :asset_group, class_name: 'AssetGroup', :foreign_key => :asset_group_id
  belongs_to :asset_fleet, class_name: 'AssetFleet', :foreign_key => :asset_fleet_id
  belongs_to :most_recent_asset_event, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :condition_event, class_name: 'ConditionUpdateEvent', :foreign_key => :condition_event_id
  belongs_to :service_status_event, class_name: 'ServiceStatusUpdateEvent', :foreign_key => :service_status_event_id
  belongs_to :rebuild_event, class_name: 'RehabilitationUpdateEvent', :foreign_key => :rebuild_event_id
  belongs_to :mileage_event, class_name: 'MileageUpdateEvent', :foreign_key => :mileage_event_id
  belongs_to :early_replacement_status_event, class_name: 'ReplacementStatusUpdateEvent', :foreign_key => :early_replacement_status_event_id


  def self.get_default_table_headers()
    ["Asset ID", "Organization", "Line (from)", "From", "Line (to)", "To", "Class", "Subtype", "Description",
     "Main Line / Division", "Branch / Subdivision", "Track", "Segment Type", "Location", "Last Life Cycle Action",
     "Life Cycle Action Date"]
  end

  def self.get_all_table_headers()
    ["Asset ID", "Organization", "Line (from)", "From", "Line (to)", "To", "Class", "Subtype", "Description",
     "Main Line / Division", "Branch / Subdivision", "Track", "Segment Type", "Location", "Last Life Cycle Action",
     "Life Cycle Action Date", "External ID", "Status", "Primary Mode", "Lat / Long", "TERM Condition", "TERM Rating",
     "Date of Condition Assessment", "Funding Program (largest %)", "Cost (Purcahse)", "Performance Restrictions",
     "Date of Performance Restriction", "Direct Capital Responsibility", "Capital Responsibility %", "Replacement Status", "NTD ID"]
  end

end