class FtaTypeAssetSubtypeMapping < ActiveRecord::Base
  belongs_to :fta_type, polymorphic: true
  belongs_to :asset_subtype
end
