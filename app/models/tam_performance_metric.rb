class TamPerformanceMetric < ActiveRecord::Base

  include TransamObjectKey

  # Callbacks
  after_initialize :set_defaults

  # Associations

  belongs_to :organization

  belongs_to :tam_group

  # Validations
  validates :tam_group,       :presence => true



  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  #default_scope {  }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :useful_life_benchmark,
    :useful_life_benchmark_unit,
    :useful_life_benchmark_locked,
    :pcnt_goal,
    :pcnt_goal_locked
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

  def organizations
    tam_group.organizations
  end


  protected

  # Set resonable defaults for a new condition update event
  def set_defaults

  end
end
