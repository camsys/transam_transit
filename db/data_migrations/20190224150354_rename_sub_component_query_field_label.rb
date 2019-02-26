class RenameSubComponentQueryFieldLabel < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_by_label('Sub-Component')
    qf.update(label: 'Sub-Component (Facilities)') if qf
  end
end