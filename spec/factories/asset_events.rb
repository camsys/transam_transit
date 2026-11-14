FactoryBot.define do

  trait :basic_event_traits do
    # TTPLAT-3112: survivor analogue of the legacy :bus fixture on the retired AssetEvent#asset link.
    # :revenue_vehicle carries no organization of its own, and a survivor needs an organization
    # whose policy has a parent (TransitAsset#check_policy_rule) -- the same setup every survivor
    # spec does by hand (see revenue_vehicle_spec.rb).
    transam_asset do
      organization = association(:organization)
      association(:policy, :organization => organization, :parent => association(:parent_policy))
      association :revenue_vehicle, :organization => organization
    end
    # Several events' set_defaults (after_initialize) read the asset; FactoryBot's default
    # `new` then setters runs it before transam_asset is assigned. Pass attributes to `new`.
    initialize_with { new(attributes) }
  end

  factory :condition_update_like_event, :class => :asset_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("ConditionUpdateEvent") }
    # This factory builds a plain AssetEvent (not the ConditionUpdateEvent subclass), which has
    # no `belongs_to :condition_type` association -- only the raw `condition_type_id` column.
    # Setting `condition_type=` here raises NoMethodError; the real accessor is `condition_type_id`.
    condition_type_id { ConditionType.find_by(name: "Adequate").id }
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
    # Required on vehicles (DispositionUpdateEvent validation); unreachable before TTPLAT-3112 because
    # set_defaults raised first under the legacy trait.
    mileage_at_disposition { 0 }
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
    # TTPLAT-3112: LocationUpdateEvent#parent is a TransamAsset; the legacy :administration_building
    # (SupportFacility < Asset) fails its type check. Survivor facility in the event asset's organization.
    # As the app does (facility.rb:159, location_update_event_loader.rb:25): the facility's TransamAsset.
    parent { association(:facility, :organization => transam_asset.organization).transam_asset }
  end

  factory :mileage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("MileageUpdateEvent") }
    current_mileage { 100000 }
  end

  factory :ntd_mileage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("NtdMileageUpdateEvent") }
    # NtdMileageUpdateEvent validates :ntd_report_mileage, not the `current_mileage` column other
    # event factories use -- the old value silently left this required field unset.
    ntd_report_mileage { 100000 }
    # event_date defaults to Date.today (AssetEvent#set_defaults), and valid_event_date rejects an
    # event_date after the end of the fiscal year named by reporting_year. A hard-coded reporting_year
    # eventually falls behind Date.today; deriving it from today's date keeps this factory valid indefinitely.
    reporting_year { NtdMileageUpdateEvent.new.fiscal_year_year_on_date(Date.today) }
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
    # validates :vehicle_usage_codes presence; same value the usage-codes view spec merges in by hand.
    vehicle_usage_codes { [VehicleUsageCode.first] }
  end

  factory :vehicle_usage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by_class_name("VehicleUsageUpdateEvent") }
    avg_daily_use_hours { 10 }
  end

end
