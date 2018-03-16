class TamGroup < ActiveRecord::Base

  include TransamObjectKey

  include TransamWorkflow

  # Callbacks
  after_initialize :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  # Associations

  belongs_to :tam_policy

  has_many :tam_performance_metrics, :dependent => :destroy

  belongs_to :leader, :class_name => 'User', :foreign_key => :leader_id

  belongs_to :organization

  has_and_belongs_to_many :organizations, :join_table => 'tam_groups_organizations'

  has_and_belongs_to_many :fta_asset_categories, :join_table => 'tam_groups_fta_asset_categories'

  # Every policy can have a parent policy
  belongs_to  :parent, :class_name => 'TamGroup', :foreign_key => :parent_id

  # Validations
  validates :tam_policy,       :presence => true
  validates :leader_id,        :presence => true
  validates :name,             :presence => true
  validates_length_of :name,   :maximum => 50

  validates :fta_asset_categories, :presence => true

  #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the state of a form through the approval process
  #
  #------------------------------------------------------------------------------
  state_machine :state, :initial => :inactive do # override this initial state when distributing to orgs

    #-------------------------------
    # List of allowable states
    #-------------------------------
    state :inactive

    state :in_development

    state :distributed

    state :pending_activation

    state :activated

    state :archived


    #---------------------------------------------------------------------------
    # List of allowable events. Events transition a Form from one state to another
    #---------------------------------------------------------------------------

    event :generate do
      transition :inactive => :in_development
    end

    event :distribute do
      transition :in_development => :distributed
    end

    event :activate do
      transition :pending_activation => :activated
    end

    event :archive do
      transition :activated => :archived
    end

    # Callbacks
    before_transition do |form, transition|
      Rails.logger.debug "Transitioning #{form} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end

    after_transition on: :generate, do: :generate_tam_performance_metrics
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
    :organization_ids => [],
    :fta_asset_category_ids => []
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.organization_ids
    self.joins(:organizations).pluck('organizations.id')
  end


  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def to_s
    name
  end

  def has_parent?
    parent.present?
  end

  def generate_tam_performance_metrics

    sys_user = User.find_by(first_name: 'system')

    # do actions for setting tam group lead
    unless leader.roles.pluck(:name).include? 'tam_group_lead'
      # for now say role is set by system
      Rails.application.config.user_role_service.constantize.new.assign_role leader, Role.find_by(name: 'tam_group_lead'), sys_user
    end

    msg = Message.new
    msg.user          = sys_user
    msg.organization  = leader.organization
    msg.to_user       = leader
    msg.subject       = "#{tam_policy} #{self} is in development"
    msg.body          = "#{tam_policy} #{self} is in development and its group metrics can be updated."
    msg.priority_type = PriorityType.default
    msg.save


    #create performance metrics for the group
    org_ids = self.organizations.pluck(:id)
    fta_asset_categories.each do |category|
      category.asset_levels(Asset.where(organization_id: org_ids)).each do |type|
        self.tam_performance_metrics.create!(fta_asset_category: category, asset_level: type)
      end
    end

  end

  def assets(fta_asset_category=nil)
    asset_types = fta_asset_category ? fta_asset_category.asset_types : fta_asset_categories.map{|f| f.asset_types}.flatten

    Asset.operational.where(organization_id: organizations.pluck(:id), asset_type: asset_types).where.not(pcnt_capital_responsibility: nil)


  end

  def assets_past_useful_life_benchmark(fta_asset_category=nil,date=Date.today)
    categories = fta_asset_category ? [fta_asset_category] :fta_asset_categories

    categories.each do |category|
      tam_performance_metrics.where(fta_asset_category: category).each do |metric|
        if metric.useful_life_benchmark_unit == 'year'
          assets(category).where(fta_asset_category.asset_search_query(metric.asset_level)).joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, asset_id FROM asset_events GROUP BY asset_id) as rehab_events ON rehab_events.asset_id = assets.id').where('YEAR(?)-manufacture_year + IFNULL(sum_extended_eul, 0) > ?', date, metric.useful_life_benchmark)
        elsif metric.useful_life_benchmark_unit == 'condition_rating'
          assets(category).where(fta_asset_category.asset_search_query(metric.asset_level)).where('reported_condition_rating < ?', metric.useful_life_benchmark)
        else
          assets.none
        end
      end
    end
  end


  def dup
    super.tap do |new_group|
      self.tam_performance_metrics.each do |metric|
        new_metric = metric.dup
        new_metric.object_key = nil
        new_group.tam_performance_metrics << new_metric
      end
      new_group.fta_asset_categories = self.fta_asset_categories
    end
  end

  def distribute
    initial_state_for_dup = :activated

    new_group = self.dup

    new_group.tam_performance_metrics.each do |metric|
      metric.parent = self.tam_performance_metrics.find_by(asset_level: metric.asset_level)
      initial_state_for_dup = :pending_activation if (!metric.useful_life_benchmark_locked || !metric.pcnt_goal_locked)
    end
    new_group.state = initial_state_for_dup

    new_group
  end

  # any users that could be notified of changes
  def recipients
    organization.users.with_role(:transit_manager) if organization.present?
  end

  def email_enabled?
    true
  end

  def allowed_organizations
    TransitOperator.where(id: (Asset.operational.pluck('DISTINCT organization_id') - (tam_policy.try(:tam_groups).try(:organization_ids) || []) + organization_ids))
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults

  end

  def clean_habtm_relationships
    organizations.clear
    fta_asset_categories.clear
  end

end
