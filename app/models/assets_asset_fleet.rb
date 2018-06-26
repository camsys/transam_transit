class AssetsAssetFleet < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------

  after_initialize  :set_defaults

  scope :active, -> { where('active = 1 OR active IS NULL') }

  belongs_to :asset
  belongs_to :asset_fleet

  protected

  def set_defaults
    # an asset added to a fleet would be by default be active
    # only becomes inactive if its values as per the gorup by fields of the fleet type have changed
    self.active = self.active.nil? ? true : self.active
  end

end
