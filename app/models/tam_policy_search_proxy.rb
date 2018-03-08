class TamPolicySearchProxy < Proxy

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :fy_year
  attr_accessor :tam_group_id
  attr_accessor :organization_id
  attr_accessor :fta_asset_category_id

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates_presence_of :fy_year

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
      :fy_year,
      :tam_group_id,
      :organization_id,
      :fta_asset_category_id
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end

    set_defaults
  end

  def set_defaults

    tam_policy = TamPolicy.first

    if tam_policy
      self.fy_year ||= tam_policy.fy_year
    end
  end



end
