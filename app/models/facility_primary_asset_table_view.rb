class FacilityPrimaryAssetTableView  < ActiveRecord::Base

  def readonly?
    true
  end

  #These associations are to more quickly support the access of recent asset events for the model
  belongs_to :facility
  belongs_to :most_recent_asset_event_view, class_name: 'AssetEvent', :foreign_key => :id
  belongs_to :condition_event, class_name: 'ConditionUpdateEvent', :foreign_key => :condition_event_id
  belongs_to :service_status_event, class_name: 'ServiceStatusUpdateEvent', :foreign_key => :service_status_event_id
  belongs_to :rebuild_event, class_name: 'RehabilitationUpdateEvent', :foreign_key => :rebuild_event_id
  belongs_to :mileage_event, class_name: 'MileageUpdateEvent', :foreign_key => :mileage_event_id
  belongs_to :early_replacement_status_event, class_name: 'ReplacementStatusUpdateEvent', :foreign_key => :early_replacement_status_event_id
end