class QueryToolMoreDataTweak < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_by_name('facility_component_type')
    qf.destroy if qf

    qf = QueryField.find_by_label('Component Type')
    qf.update(label: 'Component') if qf

    qf = QueryField.find_by_label('Sub-Component Type')
    qf.update(label: 'Sub-Component') if qf
  end
end