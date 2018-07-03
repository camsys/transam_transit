class CapitalEquipment < TransamAssetRecord
  actable as: :capital_equipmentible
  acts_as :transit_asset, as: :transit_assetible

  has_many :serial_numbers, as: :identifiable, dependent: :destroy

  FORM_PARAMS = [
      :quantity,
      :quantity_unit
  ]

  protected

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
