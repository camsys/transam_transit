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
  accepts_nested_attributes_for :ntd_facilities, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  # Service vehicle fleets
  has_many    :ntd_service_vehicle_fleets, :dependent => :destroy
  accepts_nested_attributes_for :ntd_service_vehicle_fleets, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  # Revenue vehicle fleets
  has_many    :ntd_revenue_vehicle_fleets, :dependent => :destroy
  accepts_nested_attributes_for :ntd_revenue_vehicle_fleets, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }


  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

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
