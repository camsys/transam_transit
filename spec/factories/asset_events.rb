FactoryBot.define do

  trait :basic_event_traits do
    association :asset, :factory => :bus
  end

  factory :condition_update_like_event, :class => :asset_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("ConditionUpdateEvent") }
    condition_type { ConditionType.find_by(:name => "Adequate") }
    assessed_rating { 3 }
    event_date { "2014-01-01 12:00:00" }
    current_mileage { 25000 }
  end

  factory :condition_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("ConditionUpdateEvent") }
    condition_type { ConditionType.find_by(:name => "Adequate") }
    assessed_rating { 3 }
    event_date { "2014-01-01 12:00:00" }
    current_mileage { 25000 }
  end

  factory :disposition_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("DispositionUpdateEvent") }
    disposition_type { DispositionType.find_by(:name => "Public Sale") }
    sales_proceeds { 25000 }
    event_date { Date.today }
    #mileage_at_disposition 0
  end

  factory :service_status_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("ServiceStatusUpdateEvent") }
    service_status_type_id { 2 }
    event_date { Date.today }
  end

  factory :location_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("LocationUpdateEvent") }
    association :parent, :factory => :administration_building
  end

  factory :mileage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("MileageUpdateEvent") }
    current_mileage { 100000 }
  end

  factory :ntd_mileage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("NtdMileageUpdateEvent") }
    current_mileage { 100000 }
    reporting_year { 2013 }
  end

  factory :schedule_disposition_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("ScheduleDispositionUpdateEvent") }
    disposition_date { Date.today + 8.years }
  end

  factory :schedule_replacement_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("ScheduleReplacementUpdateEvent") }
    # Note that this can have either a replacement or a rebuild year, but it needs at least one
  end

  factory :maintenance_provider_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("MaintenanceProviderUpdateEvent") }
    maintenance_provider_type_id { 1 }
  end

  factory :maintenance_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("MaintenanceUpdateEvent") }
    maintenance_type_id { 1 }
  end

  factory :facility_operations_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("FacilityOperationsUpdateEvent") }
    annual_affected_ridership { 100 }
  end

  factory :operations_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("OperationsUpdateEvent") }
    annual_insurance_cost { 1000 }
  end

  factory :storage_method_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("StorageMethodUpdateEvent") }
    vehicle_storage_method_type_id { 1 }
  end

  factory :usage_codes_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("UsageCodesUpdateEvent") }
  end

  factory :vehicle_usage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("VehicleUsageUpdateEvent") }
    avg_daily_use_hours { 10 }
  end

end
