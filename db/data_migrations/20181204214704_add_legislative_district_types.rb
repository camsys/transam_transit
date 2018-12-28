class AddLegislativeDistrictTypes < ActiveRecord::DataMigration
  def up

    DistrictType.create(name: 'House', description: 'House Congressional District.', active: true) if DistrictType.find_by(name: 'House').nil?
    DistrictType.create(name: 'Senate', description: 'Senate Congressional District.', active: true) if DistrictType.find_by(name: 'Senate').nil?
    DistrictType.create(name: 'Federal', description: 'Federal Congressional District.', active: true) if DistrictType.find_by(name: 'Federal').nil?

  end
end