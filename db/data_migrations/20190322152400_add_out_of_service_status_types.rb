class AddOutOfServiceStatusTypes < ActiveRecord::DataMigration
  def up
    out_of_service_status_types = [
      { name: "In Storage", description: "In Storage", active: true },
      { name: "Short Term - Minor Repairs", description: "Short Term - Minor Repairs", active: true },
      { name: "Short Term - Routine Maintenance", description: "Short Term - Routine Maintenance", active: true },
      { name: "Long Term - Major Repairs", description: "Long Term - Major Repairs", active: true },
      { name: "Awaiting Sale or disposal", description: "Awaiting Sale or disposal", active: true }
    ]

    out_of_service_status_types.each{|type| OutOfServiceStatusType.create!(type)}
  end
end