#
# Disposition update event. This is event type is required for
# all implementations
#
class DispositionUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults
  after_save       :update_asset

  # Associations

  # Alias current_mileage to mileage_disposition so we can re-use the existing attribute
  alias_attribute :mileage_at_disposition,  :current_mileage
  # Alias age_at_disposition to replacement_year so we can re-use the existing attribute
  alias_attribute :age_at_disposition,      :replacement_year

  # Disposition of the asset
  belongs_to  :disposition_type

  belongs_to :organization

  validates :disposition_type,      :presence => true
  validates :sales_proceeds,        :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :mileage_at_disposition,:presence => { :message => "Cannot be blank for Revenue Vehicles or Support Vehicles" }, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, if: Proc.new { |event| event.transam_asset.very_specific.class.name.include? 'Vehicle' }
  validates :comments,              :presence => { :message => 'Cannot be blank if you selected "Other" as the Disposition Type' }, if: Proc.new { |event| event.disposition_type.name == "Other" }
  validates :organization_id,   :presence => { :message => 'Cannot be blank if you selected "Transferred" as the Disposition Type' }, if: Proc.new { |event| event.disposition_type.name == "Transferred" }

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :disposition_type_id,
    :sales_proceeds,
    :age_at_disposition,
    :mileage_at_disposition,
    :organization_id
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

  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def sales_proceeds=(num)
    self[:sales_proceeds] = sanitize_to_int(num)
  end

  def age_at_disposition=(num)
    self[:replacement_year] = sanitize_to_int(num)
  end

  def mileage_at_disposition=(num)
    self[:current_mileage] = sanitize_to_int(num)
  end

  def get_update
    "#{disposition_type} on #{event_date}"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set reasonable defaults for a new condition update event
  def set_defaults
    super
    self.disposition_type ||= transam_asset.disposition_updates.last.try(:disposition_type)
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

  def update_asset
    AssetDispositionUpdateJob.new(transam_asset.object_key).perform
  end

end
