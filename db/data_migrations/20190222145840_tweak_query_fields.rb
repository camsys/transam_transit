class TweakQueryFields < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_by_label('Element')
    qf.update(label: 'Sub-Component (Infrastructure)') if qf
  end
end