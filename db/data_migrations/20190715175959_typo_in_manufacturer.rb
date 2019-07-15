class TypoInManufacturer < ActiveRecord::DataMigration
  def up
    Manufacturer.where(code: "EDN").update_all(name: 'ElDorado National (formerly El Dorado/EBC/Nat. Coach/ NCC)')
  end
end