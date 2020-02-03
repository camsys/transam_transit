class AddEventDateToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'event_date',
        label: 'Event Date',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'date'
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'most_recent_asset_events')

    # reassign new query field to saved query fields that use the old field

    disposition_field = QueryField.find_by(name: "disposition_date")

    SavedQueryField.where(query_field: disposition_field).each do |sqf|
      sqf.update(query_field: qf)
      output_fields = sqf.saved_query.ordered_output_field_ids
      if output_fields.include? disposition_field.id
        sqf.saved_query.update(ordered_output_field_ids: output_fields.map{|id| id == disposition_field.id ? qf.id : id})
      end
    end

    # check for any saved filters using the old field before deleting
    # if there are existing filters, stop the migration and print details so the developer can resolve manually
    QueryFilter.where(query_field: disposition_field).each do |filter|
      puts "Cannot remove old query field #{disposition_field.name}, as it is being used by query filter #{filter.id}, where #{disposition_field.name} #{filter.op} #{filter.value}}."
      puts "Please check to see if the filter value(s) are manually adjustable to match with the new query field, then re-run the migration once all conflicts have been resolved."
      exit(false)
    end

    disposition_field&.destroy
  end
end