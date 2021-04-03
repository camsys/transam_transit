module BelongsToFtaType
  #-----------------------------------------------------------------------------
  #
  # BelongsToFtaType
  #
  # Mixin that adds polymorphic association to FtaType
  #
  #-----------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do
    belongs_to :fta_type, polymorphic: true, inverse_of: :asset_subtypes
  end

end
