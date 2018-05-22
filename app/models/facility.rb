class Facility < ApplicationRecord
  acts_as :transit_asset, as: :transit_assetible

  belongs_to :esl_category
  belongs_to :leed_certification_type
  belongs_to :fta_private_mode
  belongs_to :land_owner_organization
  belongs_to :facility_owner_organization
end
