class QueryToolSeedDataTweak < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_by_name('gauge_unit')
    qf.update(label: 'Gauge Unit') if qf

    qf = QueryField.find_by_name('facility_component_type')
    qf.destroy if qf
  end
end