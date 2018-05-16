#------------------------------------------------------------------------------
#
# NTD Form
#
# Represents a NTD Reporting Form for Transit Operators for a fiscal year.
#
#------------------------------------------------------------------------------
class NtdForm < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear

  # Include the Workflow module
  include TransamWorkflow

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every form belongs to an organization
  belongs_to  :organization

  # Every form has a form class
  belongs_to  :form

  # Has 0 or more comments. Using a polymorphic association, These will be removed if the form is removed
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  # Form Component Associations

  # Admin/Maint facilities
  has_many    :ntd_admin_and_maintenance_facilities, :dependent => :destroy
  accepts_nested_attributes_for :ntd_admin_and_maintenance_facilities, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  # Passenger and parking facilties
  #has_many    :ntd_passenger_and_parking_facilities, :dependent => :destroy
  #accepts_nested_attributes_for :ntd_passenger_and_parking_facilities, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  # Service vehicle fleets
  has_many    :ntd_service_vehicle_fleets, :dependent => :destroy
  accepts_nested_attributes_for :ntd_service_vehicle_fleets, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  # Revenue vehicle fleets
  has_many    :ntd_revenue_vehicle_fleets, :dependent => :destroy
  accepts_nested_attributes_for :ntd_revenue_vehicle_fleets, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,        :presence => true
  validates :form,                :presence => true
  validates :fy_year,             :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 2012}

  # Agency Information -- This is cached in case the organization's personel
  # changes and we retain the original reporting name
  #------------------------------------------------------------------------------
  #validates :reporter_name,       :presence => true
  #validates :reporter_title,      :presence => true
  #validates :reporter_department, :presence => true
  #validates :reporter_email,      :presence => true
  #validates :reporter_phone,      :presence => true
  #validates :reporter_phone_ext,              :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Constants
  #------------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :organization_id,
    :fy_year,
    :reporter_name,
    :reporter_title,
    :reporter_department,
    :reporter_email,
    :reporter_phone,
    :reporter_phone_ext,
    :ntd_admin_and_maintenance_facility_ids => [],
    :ntd_passenger_and_parking_facility => [],
    :ntd_service_vehicle_fleet_ids => [],
    :ntd_revenue_vehicle_fleet_ids => []
  ]

  #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the state of a form through the approval process
  #
  #------------------------------------------------------------------------------
  state_machine :state, :initial => :unsubmitted do

    #-------------------------------
    # List of allowable states
    #-------------------------------

    # initial state. All forms are created in this state
    state :unsubmitted

    # state used to signify it has been submitted and is pending review
    state :pending_review

    # state used to signify that the form has been returned for revision.
    state :returned

    # state used to signify that the form has been approved
    state :approved

    #---------------------------------------------------------------------------
    # List of allowable events. Events transition a Form from one state to another
    #---------------------------------------------------------------------------

    # submit a form for approval. This will place the form in the approvers queue.
    event :submit do

      transition [:unsubmitted, :returned] => :pending_review

    end

    # An approver is returning the form for additional information or changes
    event :return do

      transition [:pending_review] => :returned

    end

    # An approver is approving a form
    event :approve do

      transition [:pending_review] => :approved

    end

    # Callbacks
    before_transition do |form, transition|
      Rails.logger.debug "Transitioning #{form.name} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end
  end

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

  def to_s
    "#{organization} #{name}"
  end

  def name
    fiscal_year(fy_year)
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults
    self.state ||= "unsubmitted"
    # Set the fiscal year to the current fiscal year which can be different from
    # the calendar year
    self.fy_year ||= current_fiscal_year_year - 1
  end

end
