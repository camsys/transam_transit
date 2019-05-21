#------------------------------------------------------------------------------
# AssetGroup
#
# HBTM relationship with assets. Used as a generic bucket for grouping assets
# into loosely defined collections
#
#------------------------------------------------------------------------------
class AssetFleet < ActiveRecord::Base

  DECORATOR_METHOD_SIGNATURE = /^get_(.*)$/

  # Include the object key mixin
  include TransamObjectKey

  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------

  after_initialize  :set_defaults

  # Clear the mapping table when the group is destroyed
  before_destroy { assets.clear }

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every asset group is owned by an organization
  belongs_to :organization

  belongs_to :parent,    :class_name => "AssetFleet"

  belongs_to :asset_fleet_type

  belongs_to  :creator, -> { unscope(where: :active) }, :class_name => "User", :foreign_key => :created_by_user_id

  # Every asset grouop has zero or more assets
  has_many :assets_asset_fleets

  has_and_belongs_to_many :assets, :join_table => 'assets_asset_fleets', :association_foreign_key => Rails.application.config.asset_base_class_name.foreign_key, :class_name => Rails.application.config.asset_base_class_name == 'TransamAsset' ? 'ServiceVehicle' : Rails.application.config.asset_base_class_name

  has_and_belongs_to_many :active_assets, -> { where('assets_asset_fleets.active = 1 OR assets_asset_fleets.active IS NULL') }, :join_table => 'assets_asset_fleets', :association_foreign_key => Rails.application.config.asset_base_class_name.foreign_key, :class_name => Rails.application.config.asset_base_class_name == 'TransamAsset' ? 'ServiceVehicle' : Rails.application.config.asset_base_class_name

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,              presence: true
  validates :asset_fleet_type,          presence: true
  validates :creator,                   presence: true
  #validates :ntd_id,                    presence: true

  validates_inclusion_of :active,  :in => [true, false]


  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :object_key,
      :organization_id,
      :asset_fleet_type_id,
      :fleet_name,
      :agency_fleet_id,
      :ntd_id,
      :estimated_cost,
      :year_estimated_cost,
      :notes,
      :assets_attributes => [:object_key, :asset_search_text, :_destroy]
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def as_json(options={})
    fleet_type_fields = self.group_by_fields
    super(options).merge!({
        organization: self.organization.to_s,
        total_count: self.total_count,
        active_count: self.active_count,
        useful_life_benchmark: self.useful_life_benchmark,
        useful_life_remaining: self.useful_life_remaining
    }).merge!(fleet_type_fields.each{|k,v| fleet_type_fields[k] = v.to_s})
  end

  def to_s
   label = "#{organization.short_name}"
    asset_fleet_type.label_fields.each do |field|
      label += " : " + (self.send("get_#{field}").try(:code) || self.send("get_#{field}").to_s)
    end
    label += " : #{ntd_id}" unless ntd_id.blank?

    label
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  def ntd_id_label
    'NTD ID'
  end

  def vehicles
    if Rails.application.config.asset_base_class_name == 'Asset'
      assets.first.asset_type.class_name.constantize.where(id: assets.pluck(:id))
    else
      ServiceVehicle.where(object_key: assets.pluck(:object_key))
    end
  end

  def revenue_vehicles
    if Rails.application.config.asset_base_class_name == 'Asset'
      assets.first.asset_type.class_name.constantize.where(id: assets.pluck(:id))
    else
      RevenueVehicle.where(object_key: assets.pluck(:object_key))
    end
  end

  def total_count
    assets.count
  end

  def active_count(date=Date.today)
    start_date = start_of_fiscal_year(fiscal_year_year_on_date(date)) - 1.day
    end_date = fiscal_year_end_date(date)

    if asset_fleet_type.class_name == 'RevenueVehicle'
      vehicles.operational_in_range(start_date, end_date).joins(transit_asset: [transam_asset: :service_status_updates]).where(fta_emergency_contingency_fleet: false).where.not(asset_events: {service_status_type_id: ServiceStatusType.find_by_code('O').id}).or(vehicles.operational_in_range(start_date, end_date).joins(transit_asset: [transam_asset: :service_status_updates]).where(asset_events: {out_of_service_status_type_id: OutOfServiceStatusType.where('name LIKE ?', "%#{'Short Term'}%").ids})).count
    else
      vehicles.operational_in_range(start_date, end_date).where(fta_emergency_contingency_fleet: false).count
    end

  end

  def active(date=Date.today)
    active_count(date) != 0
  end

  def ada_accessible_count
    vehicles.ada_accessible.count
  end

  def fta_emergency_contingency_count
    vehicles.where(fta_emergency_contingency_fleet: true).count
  end

  def ntd_miles_this_year(fy_year)
    total_mileage_last_year = 0
    end_year_date = end_of_fiscal_year(fy_year)
    revenue_vehicles.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', end_year_date).each do |asset|
      fy_year_ntd_mileage = asset.fiscal_year_ntd_mileage(fy_year)
      prev_year_ntd_mileage = asset.fiscal_year_ntd_mileage(fy_year - 1)
      if fy_year_ntd_mileage && prev_year_ntd_mileage
        total_mileage_last_year += fy_year_ntd_mileage - prev_year_ntd_mileage
      end
    end

    total_mileage_last_year if total_mileage_last_year > 0
  end

  def avg_active_lifetime_ntd_miles(fy_year)
    total_mileage = 0
    vehicle_count = 0
    end_year_date = end_of_fiscal_year(fy_year)
    revenue_vehicles.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', end_year_date).each do |asset|
      fy_year_ntd_mileage = asset.fiscal_year_ntd_mileage(fy_year)
      if fy_year_ntd_mileage
        vehicle_count += 1
        total_mileage += fy_year_ntd_mileage
      end
    end
    if vehicle_count > 0
      total_mileage / vehicle_count.to_i
    end
  end

  def miles_this_year(date=Date.today)
    total_miles = total_active_lifetime_miles(date)
    if total_miles
      start_date = start_of_fiscal_year(fiscal_year_year_on_date(date)) - 1.day

      total_mileage_last_year = 0
      vehicles.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', date).each do |asset|
        total_mileage_last_year += MileageUpdateEvent.where(transam_asset: asset, event_date: start_date).last.current_mileage
      end

      return total_miles - total_mileage_last_year
    end

  end

  def total_active_lifetime_miles(date=Date.today)
    start_date = start_of_fiscal_year(fiscal_year_year_on_date(date)) - 1.day
    end_date = fiscal_year_end_date(date)

    total_mileage = 0
    vehicles.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', date).each do |asset|
      if MileageUpdateEvent.unscoped.where(transam_asset: asset, event_date: [start_date, end_date]).group(:event_date).count.length == 2
        total_mileage += MileageUpdateEvent.where(transam_asset: asset, event_date: end_date).last.current_mileage
      else
        return nil
      end
    end

    return total_mileage
  end

  def avg_active_lifetime_miles(date=Date.today)
    active_assets_count = active_count(date)
    total_miles = total_active_lifetime_miles(date)
    if active_assets_count > 0 && total_miles
      total_miles / active_assets_count.to_i
    end
  end

  def useful_life_benchmark
    vehicles.first.try(:useful_life_benchmark)
  end

  def useful_life_remaining
    vehicles.first.try(:useful_life_remaining)
  end

  def rebuilt_year
    vehicles.first.try(:rebuilt_year)
  end

  # try to figure out the most commenly selected rehab/rebuilt type for revenue vehicles if they've been rebuilt
  def ntd_revenue_vehicle_rebuilt_type
    # Only applies to rebuilt RevenueVehicle fleet
    if asset_fleet_type&.class_name == 'RevenueVehicle' && rebuilt_year
      # get all latest rehab event for all assets (exclude Rebuild Type (Other) entries)
      latest_rehab_event_ids = RehabilitationUpdateEvent.where.not(vehicle_rebuild_type_id: nil)
                          .where(base_transam_asset_id: assets.pluck("transam_assets.id"))
                          .group(:base_transam_asset_id)
                          .pluck(Arel.sql("max(asset_events.id)"))
      # aggregate rebuild_type
      rebuild_types = RehabilitationUpdateEvent.joins(:vehicle_rebuild_type)
        .where(id: latest_rehab_event_ids).reorder(event_date: :desc)
        .pluck(Arel.sql("vehicle_rebuild_types.name"))

      if rebuild_types.any?
        if rebuild_types.uniq.size == 1
          # if only one, then just return it
          rebuild_types.first
        else
          # find the most commonly selected type
          type_with_count_hash = rebuild_types.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }

          # sort by count and event date and return the top 
          type_with_count_hash.sort_by{|k,v| [v*-1, rebuild_types.index(k)]}.first[0]
        end
      end
    end
  end

  def estimated_cost
    assets.sum(:purchase_cost)
  end
  def year_estimated_cost
    assets.first.manufacture_year
  end

  def group_by_fields
    a = Hash.new

    asset_fleet_type.group_by_fields.each do |field_name|
      # remove table names
      if field_name.include? '.'
        field_name = field_name.split('.')[1]
      end

      if field_name[-3..-1] == '_id'
        field = field_name[0..-4]
      else
        field = field_name
      end

      label = field_name

      a[label] = self.send('get_'+field)
    end

    a
  end


  def formatted_group_by_fields
    labels = []
    data = []
    formats = []

    asset_fleet_type.group_by_fields.each do |field_name|
      if field_name[-3..-1] == '_id'
        field = field_name[0..-4]
      else
        field = field_name
      end

      # remove table names
      if field.include? '.'
        field = field.split('.')[1]
      end

      label = field.humanize.titleize
      label = label.gsub('Fta', 'FTA')

      labels << label
      data << self.send('get_'+field)

      if [true,false].include? data[-1]
        formats << :boolean
      elsif label == label.pluralize # figure out if data is meant to be a list
        formats << :list
      elsif label[-4..-1] == 'Cost'
        formats << :currency
      elsif label[0..3] == 'Pcnt'
        formats << :percent
      else
        formats << :string
      end

    end

    {labels: labels, data: data, formats: formats}
  end

  def homogeneous?
    active_assets.count == assets.count
  end

  #-----------------------------------------------------------------------------
  # Recieves method requests. Anything that does not start with get_ is delegated
  # to the super model otherwise the request is tested against the model components
  # until a match is found or not in which case the call is delegated to the super
  # model to be evaluated
  #-----------------------------------------------------------------------------
  def method_missing(method_sym, *arguments)

    if method_sym.to_s =~ DECORATOR_METHOD_SIGNATURE
      # Strip off the decorator and see who can handle the real request
      actual_method_sym = method_sym.to_s[4..-1]
      if (asset_fleet_type.groups.include? actual_method_sym) || (asset_fleet_type.custom_groups.include? actual_method_sym) || (asset_fleet_type.label_groups.include? actual_method_sym)
        typed_asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(vehicles.first)
        typed_asset.try(actual_method_sym)
      end
    else
      puts "Method #{method_sym.to_s} with #{arguments}"
      # Pass the call on -- probably generates a method not found exception
      super
    end
  end

  protected

  def set_defaults

  end

end
