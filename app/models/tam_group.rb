class TamGroup < ActiveRecord::Base

  has_paper_trail on: [:update]

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
  validates_uniqueness_of :name,            scope: [:organization_id, :tam_policy_id], if: -> { organization_id.blank? }
  validates_uniqueness_of :parent_id,       scope: :organization_id, if: -> { organization_id.present? }


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

  def period
    if organization
      "#{Date::MONTHNAMES[organization.ntd_reporting_start_month]} - #{Date::MONTHNAMES[organization.ntd_reporting_start_month == 1 ? 12 : organization.ntd_reporting_start_month-1]}"
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
  # assets that are not disposed as of a date
  def assets(fta_asset_category=nil, end_date=Date.today)

      (TransitAsset.where(disposition_date: nil).or(TransitAsset.where('disposition_date > ?', end_date))).where(fta_asset_category: (fta_asset_category || fta_asset_categories)).where.not(pcnt_capital_responsibility: nil, transit_assetible_type: 'TransitComponent')
  end

  # TODO should probably be refactored to include organization(s)
  # TODO also refactor out asset_search_query
  # assets that are past their ULB as of a date
  def assets_past_useful_life_benchmark(fta_asset_category, tam_performance_metric=nil, date=Date.today)

    assets_past = []

    metrics = tam_performance_metric.present? ? TamPerformanceMetric.where(object_key: tam_performance_metric.object_key) : tam_performance_metrics

    metrics.where(fta_asset_category: fta_asset_category).each do |metric|
      if metric.useful_life_benchmark_unit == 'year'
        assets_past << assets(fta_asset_category, date).joins(:transam_asset).where(fta_asset_category.asset_search_query(metric.asset_level)).joins('LEFT JOIN (SELECT coalesce(SUM(extended_useful_life_months)) as sum_extended_eul, base_transam_asset_id FROM asset_events GROUP BY base_transam_asset_id) as rehab_events ON rehab_events.base_transam_asset_id = transam_assets.id').where('YEAR(?)-manufacture_year + IFNULL(sum_extended_eul, 0) >= ?', date, metric.useful_life_benchmark)
      elsif metric.useful_life_benchmark_unit == 'condition_rating'
        assets = assets(fta_asset_category, date).where(fta_asset_category.asset_search_query(metric.asset_level))

        assets.each do |x|
          condition_rating = x.condition_updates.where('event_date <= ?', date).last.try(:assessed_rating)
          assets_past << x if condition_rating.present? && condition_rating < metric.useful_life_benchmark
        end
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

      new_metric.tam_group = new_group # explicitly set group before adding to parent so validation passes
      new_group.tam_performance_metrics << new_metric if new_metric.valid?
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

  def message_template
    templates = MessageTemplate.all

    if state == 'in_development'
      templates.find_by(name: 'TamPolicy1')
    elsif state == 'distributed'
      templates.find_by(name: 'TamPolicy2')
    elsif state == 'activated'
      templates.find_by(name: 'TamPolicy3')
    end
  end

  def message_subject
    message_template.try(:subject)
  end

  def message_body
    if state == 'in_development'
      custom_fields = ["#{self}","#{tam_policy}", "<a href='#{Rails.application.routes.url_helpers.tam_groups_rule_set_tam_policies_path(RuleSet.find_by(class_name: "TamPolicy"),fy_year: tam_policy.fy_year, tam_group: self.object_key)}'>here</a>"]
    elsif state == 'distributed'
      custom_fields = ["#{self}","#{tam_policy}","#{self}", "<a href='#{Rails.application.routes.url_helpers.tam_metrics_rule_set_tam_policies_path(RuleSet.find_by(class_name: "TamPolicy"),fy_year: tam_policy.fy_year, tam_group: self.object_key)}'>here</a>"]
    elsif state == 'activated'
      custom_fields = ["#{organization}", "#{self}", "#{tam_policy}", "#{organization}", "<a href='#{Rails.application.routes.url_helpers.tam_metrics_rule_set_tam_policies_path(RuleSet.find_by(class_name: "TamPolicy"),fy_year: tam_policy.fy_year, tam_group: self.object_key, organization: organization.short_name)}'>here</a>"]
    end

    MessageTemplateMessageGenerator.new.generate(message_template, custom_fields) if message_template
  end

  def allowed_organizations
    TransitOperator.where(id: (Rails.application.config.asset_base_class_name.constantize.operational.pluck('DISTINCT organization_id') - (tam_policy.try(:tam_groups).try(:organization_ids) || []) + organization_ids))
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
