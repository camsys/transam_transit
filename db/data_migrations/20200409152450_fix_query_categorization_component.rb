class FixQueryCategorizationComponent < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'component_type_id').update!(query_category_id: QueryCategory.find_by(name: 'Identification & Classification').id)
  end
end