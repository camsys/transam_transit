class FacilityComponent < TransitComponent

  before_update :update_identification

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'Facility')) }

  validates :manufacture_year, presence: true
  validates :description, presence: true
  validate :valid_categorization

  FORM_PARAMS = [
      :serial_number_strings
  ]

  def serial_number_strings
    serial_numbers.pluck(:identification).join("\n")
  end

  def serial_number_strings=(strings)
    # HACK: Temporary use of big hammer while developing
    serial_numbers.destroy_all
    strings.split("\n").each do |sn|
      SerialNumber.create(identifiable_type: 'TransamAsset',
                          identifiable_id: self.id,
                          identification: sn)
    end
  end

  def categorization
    if component_type.present? && component_subtype.nil?
      TransitAsset::CATEGORIZATION_COMPONENT
    elsif component_subtype.present? && component_type.nil?
      TransitAsset::CATEGORIZATION_SUBCOMPONENT
    end
  end

  def categorization_string
    case categorization
    when TransitAsset::CATEGORIZATION_PRIMARY
      "Primary"
    when TransitAsset::CATEGORIZATION_COMPONENT
      "Component"
    when TransitAsset::CATEGORIZATION_SUBCOMPONENT
      "Sub-Component"
    end
  end
  
  protected

  def valid_categorization
    if (component_type_id.present? && component_subtype_id.present?) || (component_type_id.nil? && component_subtype_id.nil?)
      errors.add(:categorization, "must exist")
    end
  end

  def update_identification
    typed_parent = TransamAsset.get_typed_asset(parent)

    self.fta_asset_class = typed_parent.fta_asset_class
    self.fta_type = typed_parent.fta_type
    self.asset_subtype = typed_parent.asset_subtype
  end


end
