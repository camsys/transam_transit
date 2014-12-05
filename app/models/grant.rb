#------------------------------------------------------------------------------
#
# Grant
#
# Represents a federal, state or other type of grant where the transit
# agency is the recipient.
#
#------------------------------------------------------------------------------
class Grant < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every funding line item belongs to an organization
  belongs_to  :organization

  # Has a single funding source
  belongs_to  :funding_source

  # Has many grant purchases
  has_many :grant_purchases

  # Has many assets through grant purchases
  has_many :assets, :through => :grant_purchases

  # Has 0 or more documents. Using a polymorphic association. These will be removed if the Grant is removed
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,                    :presence => true
  validates :fy_year,                         :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1970}
  validates :funding_source,                  :presence => true
  validates :amount,                          :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :organization_id,
    :funding_source_id,
    :fy_year,
    :amount,
    :active
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

  # Calculate the anount of teh greant that has been spent on assets to date. This calculates
  # only the federal percentage
  def spent
    val = 0
    grant_purchases.includes(:asset).each do |p|
      val += p.asset.purchase_cost * (p.pcnt_purchase_cost / 100.0)
    end
    val
  end
  # Generates a cash flow summary for the funding line item
  def cash_flow

    a = []
    cash_balance = amount - spent

    (fy_year..last_fiscal_year_year).each_with_index do |yr, idx|
      year_committed = 0

      list = funding_requests
      list.each do |fr|
        if fr.activity_line_item.capital_project.fy_year == yr
          year_committed += federal? ? fr.federal_amount : fr.state_amount
        end
      end

      cash_balance -= year_committed

      # Add this years summary to the array
      if idx == 0
        a << [fiscal_year(yr), amount, spent, year_committed, cash_balance]
      else
        a << [fiscal_year(yr), 0, 0, year_committed, cash_balance]
      end
    end
    a
  end

  # Returns the set of funding requests for this funding line item
  def funding_requests

    if federal?
      FundingRequest.where('federal_funding_line_item_id = ?', id)
    else
      FundingRequest.where('state_funding_line_item_id = ?', id)
    end

  end

  # returns the amount of funds committed but not spent
  def committed
    val = 0
    # TODO: filter this amount by requests that have not been committed
    funding_requests.each do |req|
      if federal?
        val += req.federal_amount
      else
        val += req.state_amount
      end
    end
    val
  end

  # Returns the balance of the fund. If the account is overdrawn
  # the amount will be < 0
  def balance
    amount - spent - committed
  end

  # Returns the amount of funds available. This will return 0 if the account is overdrawn
  def available
    [balance, 0].max
  end

  # Returns the amount that is not earmarked for operating assistance
  def non_operating_funds
    amount - operating_funds
  end

  # Returns the amount of the fund that is earmarked for operating assistance
  def operating_funds

    amount * (pcnt_operating_assistance / 100.0)

  end

  # Returns true if the funding line item is associated with a federal fund, false otherwise
  def federal?

    if funding_source
      funding_source.federal?
    else
      false
    end

  end

  # Override the mixin method and delegate to it
  def fiscal_year(year = nil)
    if year
      super(year)
    else
      super(fy_year)
    end
  end

  def to_s
    name
  end

  def name
    grant_number.blank? ? 'N/A' : grant_number
  end

  def details
    if project_number.blank?
      "#{funding_source} #{fiscal_year} ($#{available})"
    else
      "#{funding_source} #{fiscal_year}: #{project_number} ($#{available})"
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults

    self.amount ||= 0

    # Set the fiscal year to the current fiscal year which can be different from
    # the calendar year
    self.fy_year ||= current_fiscal_year_year + 1

  end

end
