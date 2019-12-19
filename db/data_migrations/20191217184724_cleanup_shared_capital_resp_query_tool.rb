class CleanupSharedCapitalRespQueryTool < ActiveRecord::DataMigration
  def up
    [{
        name: 'shared_capital_responsibility_organization_id',
        label: 'Organization with Shared Capital Responsibility',
        filter_type: 'multi_select',
        pairs_with: 'other_shared_capital_responsibility',
        association: {
            table_name: 'organizations',
            display_field_name: 'short_name'
        }
    },
    {
        name: 'other_shared_capital_responsibility',
        label: 'Organization with Shared Capital Responsibility (Other)',
        filter_type: 'text',
        hidden: true
    }
    ].each do |query_field_params|
      query_field = QueryField.find_by(name: query_field_params[:name])
      if query_field
        query_field.update!(query_field_params.except(:association).merge(query_category: QueryCategory.find_by(name: 'Funding')))
      else
        query_field = QueryField.create!(query_field_params.except(:association).merge(query_category: QueryCategory.find_by(name: 'Funding')))
      end

      if query_field_params[:association]
        assoc = QueryAssociationClass.find_or_create_by(query_field_params[:association])

        query_field.update!(query_association_class: assoc)
      end
    end


  end
end