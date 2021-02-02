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
    
    scope :with_fta_type, ->(type) {
      joins(:fta_type_asset_subtype_mappings)
        .where(fta_type_asset_subtype_mappings: {fta_type_type: type.class.name, fta_type_id: type.id})
    }

    def fta_types
      fta_type_asset_subtype_mappings.map{|m| m.fta_type}
    end
  end

end
