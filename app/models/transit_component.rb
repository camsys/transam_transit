class TransitComponent < TransamAssetRecord
  self.child_asset_class = true

  acts_as :transit_asset, as: :transit_assetible

  belongs_to :component_type
  belongs_to :component_subtype
  belongs_to :component_element


  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  FORM_PARAMS = [
      :id,
      :component_type_id,
      :component_subtype_id,
      :component_element_id,
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

  def categorization
    if component_type.present? && component_subtype.nil?
      TransitAsset::CATEGORIZATION_COMPONENT
    elsif component_subtype.present?
      TransitAsset::CATEGORIZATION_SUBCOMPONENT
    end
  end

  def categorization_name
    if categorization == TransitAsset::CATEGORIZATION_COMPONENT
      "Component"
    else
      "Sub Component"
    end
  end

  def type_or_subtype_name
    if categorization == TransitAsset::CATEGORIZATION_COMPONENT
      component_type.to_s
    else
      component_subtype.to_s
    end
  end


  ######## API Serializer ##############
  def api_json(options={})
    transit_asset.api_json(options).merge(
    {
      component_type: component_type.try(:api_json, options),
      component_subtype: component_subtype.try(:api_json, options),
      component_element: component_element.try(:api_json, options)
    })
  end

end
