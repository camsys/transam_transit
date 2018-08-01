class Component < TransamAssetRecord
  acts_as :transit_asset, as: :transit_assetible

  belongs_to :component_type
  belongs_to :component_subtype

  FORM_PARAMS = [
      :component_type_id,
      :component_subtype_id
  ]

  CLEANSABLE_FIELDS = [

  ]

  def dup
    super.tap do |new_asset|
      new_asset.transit_asset = self.transit_asset.dup
    end
  end

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method #{method}"
      Rails.logger.warn "You are calling the old asset for this method #{method}"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

end
