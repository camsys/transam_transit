class AssetsFtaModeType < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------

  belongs_to  :asset
  belongs_to  :transam_asset, polymorphic: true

  belongs_to  :fta_mode_type


  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  #validates :asset,    :presence => true
  validates :fta_mode_type,    :presence => true

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  scope :is_primary, -> { where(is_primary: true) }
  scope :is_not_primary, -> { where('is_primary != 1 OR is_primary IS NULL') }

  # List of allowable form param hash keys
  FORM_PARAMS = [
      :id,
      :asset_id,
      :fta_mode_type_id
  ]

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new user role
  def set_defaults
    self.is_primary = self.is_primary.nil? ? false : self.is_primary
  end

  #-----------------------------------------------------------------------------
  # Private Methods
  #-----------------------------------------------------------------------------

end
