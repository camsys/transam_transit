class FacilityComponent < Component

  validates :description, presence: true
  validate :valid_facility_categorization

  def facility_categorization
    if component_type.present? && component_subtype.nil?
      Facility::CATEGORIZATION_PRIMARY
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


end
