#
# NTD Mileage update event. 
#
class NtdMileageUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults


  validates :ntd_report_mileage, :presence => true, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true}
  validate  :monotonically_increasing_mileage
  validates :reporting_year, :presence => true
  validate  :valid_event_date
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :ntd_report_mileage,
    :reporting_year
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

  def ntd_report_mileage=(num)
    unless num.blank?
      self[:ntd_report_mileage] = sanitize_to_int(num)
    end
  end      

  # This must be overriden otherwise a stack error will occur  
  def get_update
    "End of Year #{reporting_year} Odometer Reading for NTD A-30 recorded as #{ntd_report_mileage} miles." unless ntd_report_mileage.nil?
  end
  
  protected

  # Set resonable defaults for a new mileage update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    

  # Ensure that the mileage is between the previous (if any) and the following (if any)
  # Mileage must increase OR STAY THE SAME over time
  def monotonically_increasing_mileage
    if transam_asset
      previous_mileage_update = transam_asset.asset_events
                                    .where.not(ntd_report_mileage: nil)
                                    .where("reporting_year < ?", self.reporting_year ) 
                                    .where('object_key != ?', self.object_key)
                                    .order(reporting_year: :desc).first
      next_mileage_update = transam_asset.asset_events
                                .where.not(ntd_report_mileage: nil)
                                .where('reporting_year > ?', self.reporting_year) 
                                .where('object_key != ?', self.object_key)
                                .order(:reporting_year).first

      if previous_mileage_update
        errors.add(:ntd_report_mileage, "can't be less than last report (#{previous_mileage_update.ntd_report_mileage}) for year #{previous_mileage_update.reporting_year}") if ntd_report_mileage < previous_mileage_update.ntd_report_mileage
      end
      if next_mileage_update
        errors.add(:ntd_report_mileage, "can't be more than next report (#{next_mileage_update.ntd_report_mileage}) for year #{next_mileage_update.reporting_year}") if ntd_report_mileage > next_mileage_update.ntd_report_mileage
      end
    end
  end

  # does not allow a date beyond the last day of the reporting period
  # i.e. can't be later than 06/30/2018, if reporting year is 2018.
  def valid_event_date
    if event_date && reporting_year
      last_date = end_of_fiscal_year(reporting_year)
      if event_date > last_date
        errors.add(:event_date, "The Date of Report cannot be later than the last day of your NTD reporting period. You have selected #{reporting_year} as your Reporting Year, the Date of Report cannot occur after #{last_date.strftime("%m/%d/%Y")}.")
      end
    end
  end
  
end
