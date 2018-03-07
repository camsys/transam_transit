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
    # metrics from tam group with many orgs is only editable while in development
    if !organization.present? && !has_parent?
      tam_group.in_development?
    else
      !(field.include? 'locked') && !parent.send("#{field}_locked") && tam_group.pending_activation?
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

  def assets
    if organization.present?
      assets = Asset.operational.where(organization_id: organization.id, asset_type: fta_asset_category.asset_types).where.not(pcnt_capital_responsibility: nil)
    else
      assets = Asset.operational.where(organization_id: organizations.pluck(:id), asset_type: fta_asset_category.asset_types).where.not(pcnt_capital_responsibility: nil)
    end

    class_type_search = Hash.new
    class_or_types = fta_asset_category.class_or_types
    class_type_search["#{asset_level_type.underscore}_id"] = asset_level_id

    assets.where(class_type_search)
  end

  def assets_past_useful_life_benchmark(date=Date.today)
    if useful_life_benchmark_unit == 'year'
      assets.joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id').where('YEAR(?)-manufacture_year + IFNULL(sum_extended_eul, 0) > ?', date, useful_life_benchmark)
    elsif useful_life_benchmark_unit == 'condition'
      assets.where('reported_condition_rating < ?', useful_life_benchmark)
    else
      assets.none
    end
  end


  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    # should set the default based on category
    default = self.fta_asset_category.default_useful_life_benchmark_with_unit
    self.useful_life_benchmark ||= default[0]
    self.useful_life_benchmark_locked = self.useful_life_benchmark_locked.nil? ? false : self.useful_life_benchmark_locked
    self.useful_life_benchmark_unit ||= default[1]

    self.pcnt_goal ||= 0
    self.pcnt_goal_locked = self.pcnt_goal_locked.nil? ? false : self.pcnt_goal_locked

  end
end
