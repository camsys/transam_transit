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

  belongs_to :leader, -> { unscope(where: :active) }, :class_name => 'User', :foreign_key => :leader_id

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
      transition :distributed => :activated, if: ->(group) {!group.organization_id.present?}
      transition :pending_activation => :activated, if: ->(group) {group.organization_id.present?}
    end

    event :archive do
      transition :activated => :archived
    end

    # Callbacks
    before_transition do |form, transition|
      Rails.logger.debug "Transitioning #{form} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end

    after_transition on: :generate, do: :generate_tam_performance_metrics
    after_transition on: :activate, do: :check_parent_for_all_activated
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
    :organization_ids,
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

  def period
    if organization
      "#{Date::MONTHNAMES[organization.ntd_reporting_start_month]} - #{Date::MONTHNAMES[organization.ntd_reporting_start_month == 1 ? 12 : start_months[0]-1]}"
    else
      start_months = organizations.distinct.pluck(:ntd_reporting_start_month)
      if start_months.count == 1
        "#{Date::MONTHNAMES[start_months[0]]} - #{Date::MONTHNAMES[start_months[0] == 1 ? 12 : start_months[0]-1]}"
      else
        "Multiple"
      end
    end
  end

  def generate_tam_performance_metrics

    sys_user = User.find_by(first_name: 'system')

    # do actions for setting tam group lead
    unless leader.roles.pluck(:name).include? 'tam_group_lead'
      # for now say role is set by system
      Rails.application.config.user_role_service.constantize.new.assign_role leader, Role.find_by(name: 'tam_group_lead'), sys_user
    end

    #create performance metrics for the group
    org_ids = self.organizations.pluck(:id)
    fta_asset_categories.each do |category|
      transit_assets = TransitAsset.where(organization_id: org_ids)
      category.asset_levels(transit_assets).each do |type|
        self.tam_performance_metrics.create!(fta_asset_category: category, asset_level: type)
      end
    end

  end

  def check_parent_for_all_activated
    if parent.present? && TamGroup.where(parent: parent).pluck('DISTINCT state') == ['activated']
      parent.fire_state_event(:activate)
    end
  end

  # TODO should probably be refactored to include organization(s)
  def assets(fta_asset_category=nil)
    TransitAsset.operational.where(fta_asset_category: (fta_asset_category || fta_asset_categories)).where.not(pcnt_capital_responsibility: nil)
  end

  # TODO should probably be refactored to include organization(s)
  # TODO also refactor out asset_search_query
  def assets_past_useful_life_benchmark(fta_asset_category, tam_performance_metric=nil)

    assets_past = []

    metrics = tam_performance_metric.present? ? TamPerformanceMetric.where(object_key: tam_performance_metric.object_key) : tam_performance_metrics

    metrics.where(fta_asset_category: fta_asset_category).each do |metric|
      if metric.useful_life_benchmark_unit == 'year'
        assets_past << assets(fta_asset_category).joins(:transam_asset).where(fta_asset_category.asset_search_query(metric.asset_level)).joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id').where('YEAR(?)-manufacture_year + IFNULL(sum_extended_eul, 0) >= ?', Date.today, metric.useful_life_benchmark)
      elsif metric.useful_life_benchmark_unit == 'condition_rating'
        assets_past << assets(fta_asset_category).where(fta_asset_category.asset_search_query(metric.asset_level)).select{|x| x.reported_condition_rating.present? && x.reported_condition_rating <= metric.useful_life_benchmark}
      end
    end

    assets_past.flatten
  end


  def dup
    super.tap do |new_group|
      new_group.fta_asset_categories = self.fta_asset_categories
    end
  end

  def distribute
    initial_state_for_dup = :activated

    new_group = self.dup

    self.tam_performance_metrics.each do |metric|
      new_metric = metric.dup
      new_metric.object_key = nil

      new_metric.parent = metric
      initial_state_for_dup = :pending_activation if (!metric.useful_life_benchmark_locked || !metric.pcnt_goal_locked)

      new_group.tam_performance_metrics << new_metric
    end
    new_group.state = initial_state_for_dup

    if initial_state_for_dup == :activated
      event_url = Rails.application.routes.url_helpers.tam_metrics_rule_set_tam_policies_path(RuleSet.find_by(class_name: 'TamPolicy'))
      notification = Notification.create(text: "TAM performance measures for #{new_group.organization} has been activated, associated with the TAM Group: #{new_group} for #{new_group.tam_policy.to_s}.", link: event_url, notifiable_type: 'Organization', notifiable_id: new_group.organization_id )

      UserNotification.create(notification: notification, user: self.leader)
    end

    new_group
  end

  # any users that could be notified of changes
  def recipients
    if state == 'in_development'
      [leader]
    elsif state == 'distributed'
      organizations.map{|org| org.users.with_role(:transit_manager)}.flatten
    elsif state == 'activated'
      [parent.leader]
    end

  end

  def email_enabled?
    true
  end

  def message_subject

    if state == 'in_development'
      "TAM Group Generated"
    elsif state == 'distributed'
      "TAM Group Distributed"
    elsif state == 'activated'
      "#{organization} #{tam_policy} TAM Performance Measures Activated"
    end
  end

  def message_body
    if state == 'in_development'
      "The TAM Group: #{self}, has been generated for #{tam_policy}. You have been designated as the group lead. You must assign metrics for the group, based on asset category and asset class/type/mode. Upon completion, you must distribute group metrics. You can access the group <a href='#{Rails.application.routes.url_helpers.tam_groups_rule_set_tam_policies_path(RuleSet.find_by(class_name: "TamPolicy"),fy_year: tam_policy.fy_year, tam_group: self.object_key)}'>here</a>."
    elsif state == 'distributed'
      "The TAM Group: #{self}, has been distributed for #{tam_policy}. The TAM Group: #{self}, has been created in your TAM policy, performance measures section. If you are able to make changes to the performance measures, you may make any changes needed, and activate the performance measures. If you are not allowed to make changes, the performance measures will be activated automatically. You can access the performance measures <a href='#{Rails.application.routes.url_helpers.tam_metrics_rule_set_tam_policies_path(RuleSet.find_by(class_name: "TamPolicy"),fy_year: tam_policy.fy_year, tam_group: self.object_key)}'>here</a>."
    elsif state == 'activated'
      "#{organization} has activated the TAM performance measures, associated with the TAM Group: #{self} for #{tam_policy.to_s}.You can access the #{organization} performance measures <a href='#{Rails.application.routes.url_helpers.tam_metrics_rule_set_tam_policies_path(RuleSet.find_by(class_name: "TamPolicy"),fy_year: tam_policy.fy_year, tam_group: self.object_key, organization: organization.short_name)}'>here</a>."
    end
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
