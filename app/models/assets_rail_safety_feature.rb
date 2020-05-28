class AssetsRailSafetyFeature < ApplicationRecord

  belongs_to :revenue_vehicle, foreign_key: :transam_asset_id
  belongs_to :rail_safety_feature

end
