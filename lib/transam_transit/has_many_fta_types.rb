module HasManyFtaTypes
  #-----------------------------------------------------------------------------
  #
  # HasManyFtaTypes
  #
  # Mixin that adds polymorphic association to FtaTypes
  #
  #-----------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do
    has_many :fta_type_asset_subtype_mappings

    def fta_types
      fta_type_asset_subtype_mappings.map{|m| m.fta_type}
    end
  end

end
