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

  belongs_to  :creator, :class_name => "User", :foreign_key => :created_by_user_id

  # Every asset grouop has zero or more assets
  has_many :assets_asset_fleets

  has_and_belongs_to_many :assets, :through => :assets_asset_fleets, :join_table => 'assets_asset_fleets'
  has_and_belongs_to_many :active_assets, -> { where('assets_asset_fleets.active = 1 OR assets_asset_fleets.active IS NULL') }, :through => :assets_asset_fleets, :join_table => 'assets_asset_fleets', :class_name => 'Asset'

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,              :presence => true
  validates :asset_fleet_type,          :presence => true
  validates :creator,                   :presence => true

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
    if asset_fleet_type.class_name == 'SupportVehicle'
      'SV ID'
    else
      'RVI ID'
    end
  end

  def total_count
    assets.count
  end

  def active_count(date=Date.today)
    assets.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', date).count
  end

  def active(date=Date.today)
    active_count(date) != 0
  end

  def ada_accessible_count
    assets.where('ada_accessible_ramp=1 OR ada_accessible_lift=1').count
  end

  def fta_emergency_contingency_count
    assets.where(fta_emergency_contingency_fleet: true).count
  end

  def miles_this_year(date=Date.today)
    total_miles = total_active_lifetime_miles(date)
    if total_miles
      start_date = start_of_fiscal_year(fiscal_year_year_on_date(date)) - 1.day

      total_mileage_last_year = 0
      assets.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', date).each do |asset|
        total_mileage_last_year += MileageUpdateEvent.where(asset: asset, event_date: start_date).last.current_mileage
      end

      return total_miles - total_mileage_last_year
    end

  end

  def total_active_lifetime_miles(date=Date.today)
    start_date = start_of_fiscal_year(fiscal_year_year_on_date(date)) - 1.day
    end_date = fiscal_year_end_date(date)

    total_mileage = 0
    assets.where(fta_emergency_contingency_fleet: false).where('disposition_date IS NULL OR disposition_date > ?', date).each do |asset|
      if MileageUpdateEvent.unscoped.where(asset: asset, event_date: [start_date, end_date]).group(:event_date).count.length == 2
        total_mileage += MileageUpdateEvent.where(asset: asset, event_date: end_date).last.current_mileage
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
    Asset.get_typed_asset(active_assets.first).try(:useful_life_benchmark)
  end

  def useful_life_remaining
    Asset.get_typed_asset(active_assets.first).try(:useful_life_remaining)
  end

  def group_by_fields
    a = Hash.new

    asset_fleet_type.group_by_fields.each do |field_name|
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
        typed_asset = Asset.get_typed_asset(active_assets.first)
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
