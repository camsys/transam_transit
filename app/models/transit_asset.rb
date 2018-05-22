class TransitAsset < ApplicationRecord

  acts_as :transam_asset, as: :transam_assetible

  actable as: :transit_assetible

  belongs_to :asset
  belongs_to :fta_asset_category
  belongs_to :fta_class
  belongs_to :fta_type
  belongs_to :contract_type

  after_save :save_to_asset


  def typed_asset
    Asset.get_typed_asset(asset)
  end

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

  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && transam_asset.respond_to?(method)
      puts "A"
      transam_asset.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method"
      Rails.logger.warn "You are calling the old asset for this method"
      typed_asset.send(method, *args, &block)
    else
      puts "B"
      super
    end
  end

  protected

  def save_to_asset
    asset.update!(previous_changes)
  end
end
