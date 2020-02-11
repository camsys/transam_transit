class OrganizationViewQueryTool < ActiveRecord::DataMigration
  def up
    query_view_sql = <<-SQL
      CREATE OR REPLACE VIEW organizations_with_others_view AS
        SELECT id, short_name
        FROM organizations
        UNION SELECT NULL as id, 'Other' AS short_name
        UNION SELECT 0 as id, 'N/A' AS short_name
    SQL
    ActiveRecord::Base.connection.execute query_view_sql

    qac = QueryAssociationClass.find_or_create_by(table_name: 'organizations_with_others_view', display_field_name: 'short_name', id_field_name: 'id')
    QueryField.where(query_association_class: QueryAssociationClass.find_by(table_name: 'organizations')).where.not(name: ['organization_id', 'vendor_id']).update_all(query_association_class_id: qac.id)
  end
end