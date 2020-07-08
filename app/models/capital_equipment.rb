class CapitalEquipment < TransitAsset

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'CapitalEquipment')) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :manufacture_year, presence: true
  validates :quantity, presence: true
  validates :quantity_unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :other_manufacturer, presence: true
  validates :other_manufacturer_model, presence: true

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

  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------

  # TODO: Make this a shareable Module 
  def rowify fields=nil

    #Default Fields
    fields ||= [:asset_id,
              :org_name,
              :description,
              :manufacturer,
              :model,
              :year,
              :type,
              :subtype,
              :service_status,
              :last_life_cycle_action,
              :life_cycle_action_date]

    field_library = {
      asset_id: {label: "Asset Id", method: :asset_tag, url: "/inventory/#{self.object_key}/"},
      org_name: {label: "Organization", method: :org_name, url: nil},
      description: {label: "Description", method: :description, url: nil},
      manufacturer: {label: "Manufacturer", method: :manufacturer_name, url: nil},
      model: {label: "Model", method: :model_name, url: nil},
      year: {label: "Year", method: :manufacture_year, url: nil},
      type: {label: "Type", method: :type_name, url: nil},
      subtype: {label: "Subtype", method: :subtype_name, url: nil},
      service_status: {label: "Service Status", method: :service_status_name, url: nil},
      last_life_cycle_action: {label: "Last Life Cycle Action", method: :last_life_cycle_action, url: nil},
      life_cycle_action_date: {label: "Life Cycle Action Date", method: :life_cycle_action_date, url: nil}
    }
    
    row = {}
    fields.each do |field|
      row[field] =  {label: field_library[field][:label], data: self.send(field_library[field][:method]), url: field_library[field][:url]} 
    end
    return row 
  end

  def my_esl
    true
  end

  def org_name
    organization.try(:short_name)
  end

  def manufacturer_name
    manufacturer.try(:name)
  end

  def model_name
    (manufacturer_model.try(:name) == "Other") ? other_manufacturer_model : manufacturer_model.try(:name)
  end

  def type_name
    fta_type.try(:name)
  end

  def subtype_name
    asset_subtype.try(:name)
  end

  def service_status_name
    service_status.try(:service_status_type).try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

  def last_life_cycle_action
    history.first.try(:asset_event_type).try(:name)
  end

  def life_cycle_action_date
    history.first.try(:event_date)
  end

end
