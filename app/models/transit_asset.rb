class TransitAsset < ApplicationRecord

  acts_as :transam_asset, as: :transam_assetible

  actable as: :transit_assetible

  belongs_to :asset
  belongs_to :fta_asset_category
  belongs_to :fta_asset_class
  belongs_to :fta_type,  :polymorphic => true
  belongs_to :contract_type

  after_save :save_to_asset

  # old asset
  def typed_asset
    Asset.get_typed_asset(asset)
  end

  # given a class result set find the highest acting_as model
  def self.specific
    klass = self
    assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
    assoc_arr = Hash.new
    assoc_arr[assoc] = nil
    t = klass.distinct.where.not(assoc_arr).pluck(assoc)

    while t.count == 1
      id_col = assoc[0..-6] + '_id'
      klass = t.first.constantize.where(id: klass.pluck(id_col))
      assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
      assoc_arr = Hash.new
      assoc_arr[assoc] = nil
      t = klass.distinct.where.not(assoc_arr).pluck(assoc)
    end

    return klass

  end

  protected

  def save_to_asset
    asset.update!(previous_changes)
  end
end
