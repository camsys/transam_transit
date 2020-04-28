#
# Rehabilitation update event. This is event type is required for
# all implementations
#
class RehabilitationUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
  after_save       :update_asset
  before_destroy   :clear_out_asset_rebuilt_year
      
  # Associations
  has_many :asset_event_asset_subsystems, 
             :foreign_key => "asset_event_id", 
             :inverse_of  => :rehabilitation_update_event, 
             :dependent   => :destroy
  accepts_nested_attributes_for :asset_event_asset_subsystems, 
                                  :allow_destroy => true,
                                  :reject_if   => lambda{ |attrs| attrs[:parts_cost].blank? and attrs[:labor_cost].blank? }
  
  has_many :asset_subsystems, :through => :asset_event_asset_subsystems

  belongs_to :vehicle_rebuild_type

  validates :total_cost, presence: true
  validates :extended_useful_life_months, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, allow_nil: true
  validates :extended_useful_life_miles,  :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, allow_nil: true
        
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :total_cost,
    :extended_useful_life_months,
    :extended_useful_life_miles,
    :vehicle_rebuild_type_id,
    :other_vehicle_rebuild_type,
    :asset_event_asset_subsystems_attributes => [AssetEventAssetSubsystem.allowable_params]
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #returns the asset event type for this type of event
  def self.asset_event_type
    AssetEventType.find_by_class_name(self.name)
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def rebuild_type_name
    vehicle_rebuild_type&.name || other_vehicle_rebuild_type
  end

  def get_update
    rebuild_type = rebuild_type_name
    if rebuild_type
      "Rebuild / Rehabilitation: #{rebuild_type}: $#{cost}"
    else
      "Rebuild / Rehabilitation: $#{cost}"
    end
  end

  def cost
    if total_cost
      total_cost
    else
      parts_cost + labor_cost # sum up the costs from subsystems
    end
  end

  # Cost for each piece is the sum of what's spent on subsystems
  def parts_cost
    asset_event_asset_subsystems.map(&:parts_cost).compact.reduce(0, :+)
  end
  def labor_cost
    asset_event_asset_subsystems.map(&:labor_cost).compact.reduce(0, :+)
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      vehicle_rebuild_type: vehicle_rebuild_type.try(:api_json, options),
      other_vehicle_rebuild_type: other_vehicle_rebuild_type,
      total_cost: total_cost,
      extended_useful_life_months: extended_useful_life_months,
      extended_useful_life_miles: extended_useful_life_miles
    })
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new rehab update event
  def set_defaults
    super
    self.extended_useful_life_months ||= 0
    self.extended_useful_life_miles ||= 0
  end  

  def update_asset
    # applies to RevenueVehicle
    #   1. bus: extended useful life months >= 48
    #   2. non-bus: extended useful life months >= 120
    if extended_useful_life_months 
      specific_asset = transam_asset.very_specific
      if specific_asset.is_a?(RevenueVehicle) && ((specific_asset.fta_asset_class&.is_bus? && extended_useful_life_months >= 48) || extended_useful_life_months >= 120)
        rebuilt_year = event_date.year
        if !transam_asset.rebuilt_year || rebuilt_year > transam_asset.rebuilt_year
          transam_asset.update(rebuilt_year: rebuilt_year)
          specific_asset.check_fleet(["transam_assets.rebuilt_year"])
        end
      end
    end
  end

  def clear_out_asset_rebuilt_year
    transam_asset.update(rebuilt_year: transam_asset.rehabilitation_updates.pluck('YEAR(event_date)').max)
    transam_asset.very_specific.check_fleet(["transam_assets.rebuilt_year"])
  end
  
end
