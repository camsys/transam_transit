class FixQueryAssociationLandOwner < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'land_ownership_organization_id').update!(query_association_class: QueryAssociationClass.find_by(table_name: 'organizations'))
  end
end