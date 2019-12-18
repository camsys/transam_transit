class TransitAssetFeaturesView < ActiveRecord::Base
  self.table_name = :transit_asset_features_view
  self.primary_key = :code

  def readonly?
    true
  end

  # All types that are available
  scope :active, -> { where(:active => true) }

end
