class RevenueVehicle < TransamAssetRecord
  acts_as :service_vehicle, as: :service_vehiclible

  after_initialize :set_defaults

  before_destroy do
    fta_service_types.clear
    vehicle_features.clear
  end

  before_validation   :cleanup_others

  after_commit on: :update do
    Rails.logger.debug "revenue vehicles check fleet"

    service_vehicle.check_fleet(self.previous_changes.select{|k,v| !([[nil, ''], ['',nil]].include? v)}.keys.map{|x| 'revenue_vehicles.'+x})
  end

  belongs_to :esl_category
  belongs_to :fta_funding_type
  belongs_to :fta_ownership_type

  # Each vehicle has a set (0 or more) of vehicle features
  has_and_belongs_to_many   :vehicle_features,    :foreign_key => :transam_asset_id,    :join_table => :assets_vehicle_features

  # Each vehicle has a set (0 or more) of fta service type
  has_many                  :assets_fta_service_types,       :as => :transam_asset,    :join_table => :assets_fta_service_types
  has_many                  :fta_service_types,           :through => :assets_fta_service_types

  # These associations support the separation of service types into primary and secondary.
  has_one :primary_assets_fta_service_type, -> { is_primary },
          class_name: 'AssetsFtaServiceType', :as => :transam_asset, autosave: true, dependent: :destroy
  has_one :primary_fta_service_type, through: :primary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of service types into primary and secondary.
  has_one :secondary_assets_fta_service_type, -> { is_not_primary },
          class_name: 'AssetsFtaServiceType', :as => :transam_asset
  has_one :secondary_fta_service_type, through: :secondary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of mode types into primary and secondary.
  has_one :secondary_assets_fta_mode_type, -> { is_not_primary },
          class_name: 'AssetsFtaModeType', :as => :transam_asset
  has_one :secondary_fta_mode_type, through: :secondary_assets_fta_mode_type, source: :fta_mode_type

  # each RV has one NTD mileage report per FY year
  has_many :ntd_mileage_updates, -> {where :asset_event_type_id => NtdMileageUpdateEvent.asset_event_type.id }, :as => :transam_asset, :class_name => "NtdMileageUpdateEvent"
  

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :esl_category_id, presence: true
  validates :standing_capacity, presence: true, numericality: {greater_than_or_equal_to: 0 }
  validates :fta_funding_type_id, presence: true
  validates :fta_ownership_type_id, presence: true
  validates :dedicated, inclusion: { in: [ true, false ] }
  validates :fta_ownership_type_id, inclusion: {in: FtaOwnershipType.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.fta_ownership_type_id.present? && a.other_fta_ownership_type.present?}
  validate :primary_and_secondary_cannot_match

  def primary_and_secondary_cannot_match
    if primary_fta_mode_type && primary_fta_service_type
      if (primary_fta_mode_type == secondary_fta_mode_type) && (primary_fta_service_type == secondary_fta_service_type)
        errors.add(:primary_fta_mode_type, "and primary serivce type cannot be identical to secondary mode and service type")
      end
    end
  end

  FORM_PARAMS = [
      :esl_category_id,
      :standing_capacity,
      :fta_funding_type_id,
      :fta_ownership_type_id,
      :other_fta_ownership_type,
      :dedicated,
      :primary_fta_mode_type_id,
      :primary_fta_service_type_id,
      :secondary_fta_mode_type_id,
      :secondary_fta_service_type_id,
      :vehicle_feature_ids => [],
  ]

  CLEANSABLE_FIELDS = [

  ]

  def dup
    super.tap do |new_asset|
      new_asset.assets_fta_service_types = self.assets_fta_service_types
      new_asset.vehicle_features = self.vehicle_features
      new_asset.service_vehicle = self.service_vehicle.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.fta_ownership_type = nil
    transferred_asset.license_plate = nil

    transferred_asset.mileage_updates << self.mileage_updates.last.dup if self.mileage_updates.count > 0

    transferred_asset.save(validate: false)

    return transferred_asset
  end

  def primary_fta_service_type_id
    primary_fta_service_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_service_type_id=(num)
    build_primary_assets_fta_service_type(fta_service_type_id: num, is_primary: true)
  end

  def primary_fta_mode_service
    "#{primary_fta_mode_type.try(:code)} #{primary_fta_service_type.try(:code)}"
  end

  def secondary_fta_service_type_id
    secondary_fta_service_type.try(:id)
  end

  def secondary_fta_service_type_id=(value)
    if value.blank?
      self.secondary_assets_fta_service_type = nil
    else
      build_secondary_assets_fta_service_type(fta_service_type_id: value, is_primary: false)
    end
  end

  def secondary_fta_mode_type_id
    secondary_fta_mode_type.try(:id)
  end

  def secondary_fta_mode_type_id=(value)
    if value.blank?
      self.secondary_assets_fta_mode_type = nil
    else
      build_secondary_assets_fta_mode_type(fta_mode_type_id: value, is_primary: false)
    end
  end

  def fiscal_year_ntd_mileage_update(fy_year)
    ntd_mileage_updates.find_by_reporting_year(fy_year)
  end

  def fiscal_year_ntd_mileage(fy_year)
    # if no NTD mileage reported, fallback using MileageUpdate value
    fiscal_year_ntd_mileage_update(fy_year)&.ntd_report_mileage || fiscal_year_last_mileage(fy_year)
  end

  def ntd_reported_mileage
    ntd_mileage_updates.where.not(id: nil).last.try(:ntd_report_mileage)
  end
  
  def ntd_reported_mileage_date
    ntd_mileage_updates.where.not(id: nil).last.try(:event_date)
  end

  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------

  # TODO: Make this a shareable Module 
  def rowify
    fields = {
              asset_tag_drilldown: "Asset Id", 
              org_name: "Organization",
              serial_number: "VIN", 
              manufacturer_name: "Manufacturer",
              model_name: "Model",
              manufacture_year: "Year",
              type_name: "Type",
              subtype_name: "Subtype",
              service_status_name: "Service Status",
              last_life_cycle_action: "Last Life Cycle Action",
              life_cycle_action_date: "Life Cycle Action Date"
            }
    
    user_row = {}
    fields.each do |key,value|
      user_row[value] =  self.send(key).to_s
    end
    return user_row 
  end

  def org_name
    organization.try(:short_name)
  end

  def manufacturer_name
    manufacturer.try(:name)
  end

  def model_name
    (manufacturer_model.try(:name) == "Other") ? other_manufacturer_model : manufacturer_model.try(:name)
  end

  def type_name
    fta_type.try(:name)
  end

  def subtype_name
    asset_subtype.try(:name)
  end

  def service_status_name
    service_status.try(:service_status_type).try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

  def esl_name
    esl_category.try(:name)
  end

  def last_life_cycle_action
    history.first.try(:asset_event_type).try(:name)
  end

  def life_cycle_action_date
    history.first.try(:event_date)
  end

  def asset_tag_drilldown
    #drilldown link
    #TODO: use user path instead of hard coded html
    "<a href='/inventory/#{self.object_key}/'>#{self.asset_id}</a>"
  end

  ######## API Serializer ##############
  def api_json(options={})
      service_vehicle.api_json(options).merge(
      {
        esl_category: esl_category.try(:api_json, options),
        standing_capacity: standing_capacity,
        fta_funding_type: fta_funding_type.try(:api_json, options),
        fta_ownership_type: fta_ownership_type.try(:api_json, options),
        other_fta_ownership_type: other_fta_ownership_type,
        dedicated: dedicated,
        primary_fta_service_type: primary_fta_service_type.try(:api_json, options),
        secondary_fta_service_type: secondary_fta_service_type.try(:api_json, options),
        secondary_fta_mode_type: secondary_fta_mode_type.try(:api_json, options),
        vehicle_features: vehicle_features.map{ |f| f.try(:api_json, options) }
      })
  end
  
  protected

  def set_defaults
    self.dedicated = self.dedicated.nil? ? true: self.dedicated
  end

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset #{typed_asset.object_key} for this method #{method}"
      Rails.logger.warn "You are calling the old asset for this method #{method}"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

  def cleanup_others
    # only has value when type is one of Other types
    if self.changes.include?("fta_ownership_type_id") && self.other_fta_ownership_type.present?
      self.other_fta_ownership_type = nil unless FtaOwnershipType.where(name: 'Other').pluck(:id).include?(self.fta_ownership_type_id)
    end
  end

end
