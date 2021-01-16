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

  def field_library key 
    
    fields = {
      service_status: {label: "Service Status", method: :service_status_name, url: nil},
    }

    if fields[key]
      return fields[key]
    else #If not in this list, it may be part of TransitAsset
      return super key 
    end

  end

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

    row = {}
    fields.each do |field|
      field_data = field_library(field)
      row[field] =  {label: field_data[:label], data: self.send(field_data[:method]), url: field_data[:url]} 
    end
    return row 
  end

  def service_status_name
    service_status.try(:service_status_type).try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

end
