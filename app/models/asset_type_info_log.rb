class AssetTypeInfoLog < ApplicationRecord
  after_initialize :set_defaults

  belongs_to :transam_asset, polymorphic: true
  belongs_to :fta_asset_class
  belongs_to :fta_type, polymorphic: true
  belongs_to :asset_subtype
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id

  validates :transam_asset, presence: true

  def to_s
    "FtaAssetClass: #{fta_asset_class}, FtaType: #{fta_type}, AssetSubtype: #{asset_subtype}, modified: #{updated_at}, by: #{creator}"
  end
  
  def set_defaults
    self.creator ||= TransamHelper.system_user
  end
end
