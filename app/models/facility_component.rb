class FacilityComponent < TransitComponent

  before_update :update_identification

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'Facility')) }

  validates :manufacture_year, presence: true
  validates :description, presence: true
  validate :valid_facility_categorization

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

  def facility_categorization
    if component_type.present? && component_subtype.nil?
      Facility::CATEGORIZATION_COMPONENT
    elsif component_subtype.present? && component_type.nil?
      Facility::CATEGORIZATION_SUBCOMPONENT
    end
  end

  def facility_categorization_string
    case facility_categorization
    when Facility::CATEGORIZATION_PRIMARY
      "Primary"
    when Facility::CATEGORIZATION_COMPONENT
      "Component"
    when Facility::CATEGORIZATION_SUBCOMPONENT
      "Subcomponent"
    end
  end
  
  protected

  def valid_facility_categorization
    if (component_type_id.present? && component_subtype_id.present?) || (component_type_id.nil? && component_subtype_id.nil?)
      errors.add(:facility_categorization, "must exist")
    end
  end

  def update_identification
    typed_parent = TransamAsset.get_typed_asset(parent)

    self.fta_asset_class = typed_parent.fta_asset_class
    self.fta_type = typed_parent.fta_type
    self.asset_subtype = typed_parent.asset_subtype
  end


end
