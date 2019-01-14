class TransitComponent < TransamAssetRecord
  self.child_asset_class = true

  acts_as :transit_asset, as: :transit_assetible

  belongs_to :component_type
  belongs_to :component_element_type
  belongs_to :component_subtype


  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  FORM_PARAMS = [
      :id,
      :component_type_id,
      :component_element_type_id,
      :component_subtype_id,
      :_destroy
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
