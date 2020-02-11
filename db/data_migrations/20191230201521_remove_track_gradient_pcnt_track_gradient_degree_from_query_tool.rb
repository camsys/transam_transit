class RemoveTrackGradientPcntTrackGradientDegreeFromQueryTool < ActiveRecord::DataMigration
  def up
    old_fields = QueryField.where(name: ['track_gradient_pcnt', 'track_gradient_degree'])
    gradient_field = QueryField.find_by(name: "track_gradient")

    # reassign existing gradient query field to saved query fields and filters that use the old fields
    old_fields.each do |oqf|
      SavedQueryField.where(query_field: oqf).each do |sqf|
        sqf.update(query_field: gradient_field)
        output_fields = sqf.saved_query.ordered_output_field_ids
        if output_fields.include?(oqf.id)
          sqf.saved_query.update(ordered_output_field_ids: output_fields.map{|id| id == oqf.id ? gradient_field.id : id})
        end
      end

      QueryFilter.where(query_field: oqf).update_all(query_field_id: gradient_field.id)
    end

    old_fields&.destroy_all
  end
end