class AddServiceLifeUpdatesActivity < ActiveRecord::DataMigration
  def up
    Activity.create!({ name: 'Service Life Updates',
                       description: 'Update policy replacement year for meeting mileage, condition policy rules.',
                       show_in_dashboard: false,
                       system_activity: true,
                       frequency_quantity: 1,
                       frequency_type_id: 5,
                       execution_time: '01:01',
                       job_name: 'AssetServiceLifeUpdateJob',
                       active: true })
  end
end