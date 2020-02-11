class MoveSerialIdentificationCategoryToCharacteristicsInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'serial_identification')&.update!(query_category: QueryCategory.find_by(name: 'Characteristics'))
  end
end