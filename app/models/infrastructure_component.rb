class InfrastructureComponent < Component

  after_initialize :set_defaults


  attr_accessor :has_infrastructure_parent_changes
  before_save :check_for_infrastructure_parent_changes

  # after components are touched need to update parent
  after_save :update_infrastructure_parent_values
  after_destroy :update_infrastructure_parent_values

  belongs_to :component_material
  belongs_to :infrastructure_rail_joining
  belongs_to :infrastructure_cap_material
  belongs_to :infrastructure_foundation

  default_scope { where(fta_asset_class: FtaAssetCategory.find_by(name: 'Infrastructure').fta_asset_classes) }

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

  # override transam asset association
  def parent
    Infrastructure.find_by(id: self.parent_id)
  end

  protected

  def set_defaults
    if parent
      self.organization_id = parent.organization_id
      self.asset_subtype_id = parent.asset_subtype_id
      self.fta_asset_category_id = parent.fta_asset_category_id
      self.fta_asset_class_id = parent.fta_asset_class_id
      self.fta_type = parent.fta_type
    end
    self.purchase_cost ||= 0
    self.purchased_new = self.purchased_new.nil? ? true: self.purchased_new
    self.purchase_date ||= Date.today
    self.in_service_date ||= self.purchase_date
    self.depreciation_start_date ||= self.in_service_date

  end

  def check_for_infrastructure_parent_changes
    original = TransamAsset.find_by(id: transam_asset.id)

    if new_record? || purchase_cost != original.try(:purchase_cost) || purchase_date != original.try(:purchase_date) || purchased_new != original.try(:purchased_new)
      self.has_infrastructure_parent_changes = true
    end
    return true
  end

  def update_infrastructure_parent_values

    if self.has_infrastructure_parent_changes || destroyed?
      Rails.logger.debug "apple pie apple pie apple pie"
      parent.purchase_cost = parent.infrastructure_components.sum('transam_assets.purchase_cost')
      parent.purchase_date = parent.infrastructure_components.order('transam_assets.purchase_date').limit(1).pluck(:purchase_date).first || Date.today
      parent.purchased_new = !(parent.infrastructure_components.pluck(:purchased_new).include? false)
      parent.in_service_date = self.purchase_date
      parent.save!

      puts [parent.purchase_cost, parent.purchase_date, parent.purchased_new, parent.in_service_date].inspect

      puts "blueberry pie blueberry pie blueberry pie"
    end
  end

end
