class QueryToolSeedDataTweak < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_by_name('gauge_unit')
    qf.update(label: 'Gauge Unit') if qf

    qf = QueryField.find_by_label('Element Type')
    qf.update(label: 'Element') if qf

    qf = QueryField.find_by_label('Component / Sub-Component Type')
    qf.update(label: 'Component / Sub-Component') if qf
  end
end