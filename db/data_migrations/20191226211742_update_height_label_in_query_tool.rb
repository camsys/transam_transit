class UpdateHeightLabelInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'height')&.update!(label: 'Height (Infrastructure Primary Asset)')
  end
end