class InfrastructureComponent < Component

  after_initialize :set_defaults

  belongs_to :component_material
  belongs_to :infrastructure_rail_joining
  belongs_to :infrastructure_cap_material
  belongs_to :infrastructure_foundation

  FORM_PARAMS = [
     :component_material_id,
     :infrastructure_rail_joining_id,
     :infrastructure_measurement,
     :infrastructure_measurement_unit,
     :infrastructure_weight,
     :infrastructure_weight_unit,
     :infrastructure_diameter,
     :infrastructure_diameter_unit,
     :infrastructure_cap_material_id,
     :infrastructure_foundation_id
  ]

  protected

  def set_defaults
    parent_asset = Infrastructure.find_by(id: self.parent_id)
    puts parent_asset.inspect
    if parent_asset
      self.organization_id = parent_asset.organization_id
      self.asset_subtype_id = parent_asset.asset_subtype_id
      self.fta_asset_category_id = parent_asset.fta_asset_category_id
      self.fta_asset_class_id = parent_asset.fta_asset_class_id
      self.fta_type = parent_asset.fta_type
    end
    self.purchase_cost ||= 0
    self.purchased_new = self.purchased_new.nil? ? true: self.purchased_new
    self.purchase_date ||= Date.today
    self.in_service_date ||= self.purchase_date
    self.depreciation_start_date ||= self.in_service_date

  end

end
