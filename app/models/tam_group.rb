class TamGroup < ActiveRecord::Base

  include TransamObjectKey

  # Callbacks
  after_initialize :set_defaults

  # Associations

  belongs_to :tam_policy

  belongs_to :leader, :class_name => 'User', :foreign_key => :leader_id

  has_and_belongs_to_many :organizations

  # Every policy can have a parent policy
  belongs_to  :parent, :class_name => 'TamPolicy', :foreign_key => :parent_id

  # Validations
  validates :tam_policy,       :presence => true

  #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the state of a form through the approval process
  #
  #------------------------------------------------------------------------------
  state_machine :state, :initial => :inactive do

    #-------------------------------
    # List of allowable states
    #-------------------------------

    state :in_development

    state :distributed

    state :pending_activation

    state :activated

    state :inactive


    #---------------------------------------------------------------------------
    # List of allowable events. Events transition a Form from one state to another
    #---------------------------------------------------------------------------

    event :start do
      transition :inactive => :in_development, if: ->(group) {!group.has_parent?}
      transition :inactive => :pending_activation, if: ->(group) {group.has_parent?}
    end

    event :distribute do
      transition :in_development => :distributed
    end

    event :activate do
      transition :pending_activation => :activated
    end

    event :archive do
      transition :activated => :inactive
    end

    # Callbacks
    before_transition do |form, transition|
      Rails.logger.debug "Transitioning #{form} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end

    before_transition on: :distribute, do: :distribute
  end


  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  #default_scope {  }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :name,
    :leader_id,
    :organization_ids => []
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


  def has_parent?
    parent.present?
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults

  end

end
