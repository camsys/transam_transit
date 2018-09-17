class NtdReport < ApplicationRecord
  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to  :ntd_form

  belongs_to :creator,    :class_name => 'User', :foreign_key => :created_by_id

  # Has 0 or more comments. Using a polymorphic association, These will be removed if the form is removed
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  # Form Component Associations

  # Admin/Maint facilities
  has_many :ntd_facilities, :dependent => :destroy

  # Service vehicle fleets
  has_many    :ntd_service_vehicle_fleets, :dependent => :destroy

  # Revenue vehicle fleets
  has_many    :ntd_revenue_vehicle_fleets, :dependent => :destroy

  has_many    :ntd_infrastructures, :dependent => :destroy

  has_many    :comments,  :as => :commentable, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  default_scope { order(created_at: :desc) }

  #------------------------------------------------------------------------------
  # Constants
  #------------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :ntd_form_id,
      :ntd_facility_ids => [],
      :ntd_service_vehicle_fleet_ids => [],
      :ntd_revenue_vehicle_fleet_ids => []
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

  def to_s
    "#{created_at.to_date} #{ntd_form}"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults
  end
end
