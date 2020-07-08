class FixTypeoWithFtaClassCode < ActiveRecord::DataMigration
  def up
     FtaAssetClass.where(code: "captial_equipment").each do |c|
       puts "Fixing #{c.name}. . . "
       c.code = "capital_equipment"
       c.save
     end
  end
end