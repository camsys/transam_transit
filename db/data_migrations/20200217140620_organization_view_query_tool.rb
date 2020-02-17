class OrganizationViewQueryTool < ActiveRecord::DataMigration
  def up
    query_view_sql = <<-SQL
      CREATE OR REPLACE VIEW organizations_with_others_view AS
        SELECT id, short_name
        FROM organizations
        UNION SELECT -1 as id, 'Other' AS short_name
        UNION SELECT 0 as id, 'N/A' AS short_name
    SQL
    ActiveRecord::Base.connection.execute query_view_sql

    qac = QueryAssociationClass.find_or_create_by(table_name: 'organizations_with_others_view', display_field_name: 'short_name', id_field_name: 'id')
    query_fields = QueryField.where(query_association_class: QueryAssociationClass.find_by(table_name: 'organizations')).where.not(name: ['organization_id']).update_all(query_association_class_id: qac.id)


    # update existing other values if main association not using DEFAULT_OTHER_ID
    query_fields.each do |query_field|
      query_field.query_asset_classes.first.table_name.classify.constantize.where.not({query_field.pairs_with => [nil, '']}).update_all({query_field.name => TransamAsset::DEFAULT_OTHER_ID})
    end
  end
end