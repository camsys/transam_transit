class TamPerformanceMetric < ActiveRecord::Base

  include TransamObjectKey

  # Callbacks
  after_initialize :set_defaults

  # Associations

  belongs_to :fta_asset_category

  belongs_to :asset_level, :polymorphic => true

  belongs_to :tam_group

  belongs_to  :parent, :class_name => 'TamPerformanceMetric', :foreign_key => :parent_id

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


  def can_update?(field)
    if tam_group.tam_policy == TamPolicy.first
      # metrics from tam group with many orgs is only editable while in development
      if !organization.present? && !has_parent?
        tam_group.in_development?
      else
        !(field.include? 'locked') && !parent.send("#{field}_locked") && tam_group.pending_activation?
      end
    else
      false
    end
  end

  def has_parent?
    parent.present?
  end

  def organizations
    tam_group.organizations
  end

  def organization
    tam_group.organization
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    # should set the default based on category
    if self.fta_asset_category.try(:name) == 'Facilities'
      self.useful_life_benchmark ||= 3
      self.useful_life_benchmark_unit ||= 'condition_rating'
    elsif self.fta_asset_category.try(:name) != 'Infrastructure'
      self.useful_life_benchmark ||= self.asset_level.try(:default_useful_life_benchmark)
      self.useful_life_benchmark_unit ||= self.asset_level.try(:useful_life_benchmark_unit)
    end

    self.useful_life_benchmark_locked = self.useful_life_benchmark_locked.nil? ? false : self.useful_life_benchmark_locked

    if self.fta_asset_category.try(:name) == 'Infrastructure'
      self.pcnt_goal ||= 10
    else
      self.pcnt_goal ||= 0
    end

    self.pcnt_goal_locked = self.pcnt_goal_locked.nil? ? false : self.pcnt_goal_locked

  end
end
