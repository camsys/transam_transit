class ChangeLabelOpStatusQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'operational_service_status').update!(label: 'Operational Status')
  end
end