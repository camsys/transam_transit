class TransitAsset < ApplicationRecord

  acts_as :transam_asset, as: :transam_assetible

  actable as: :transit_assetible

  after_save :save_to_asset

  belongs_to :asset
  belongs_to :fta_asset_category
  belongs_to :fta_asset_class
  belongs_to :fta_type,  :polymorphic => true
  belongs_to :contract_type

  FORM_PARAMS = [
      :fta_asset_category_id,
      :fta_asset_class_id,
      :fta_type_type,
      :fta_type_id,
      :pcnt_capital_responsibility,
      :contract_num,
      :contract_type_id,
      :has_warranty,
      :warranty_date
  ]

  def self.very_specific
    klass = self.all
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

  # old asset
  def typed_asset
    Asset.get_typed_asset(asset)
  end

  protected

  def save_to_asset
    # only need to these field in old assets table to tie properly to policy
    if (previous_changes.keys.include? 'asset_subtype_id') || (previous_changes.keys.include? 'fuel_type_id')
      asset.update!(previous_changes)
    end
  end
end
