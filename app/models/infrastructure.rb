class Infrastructure < ApplicationRecord

  acts_as :transit_asset, as: :transit_assetible

  belongs_to :infrastructure_segment_type
  belongs_to :infrastructure_chain_type
  belongs_to :infrastructure_division
  belongs_to :infrastructure_subdivision
  belongs_to :infrastructure_track
  belongs_to :infrastructure_gauge_type
  belongs_to :infrastructure_reference_rail
  belongs_to :land_ownership_organization, class_name: 'Organization'
  belongs_to :shared_capital_responsibility_organization, class_name: 'Organization'

end
