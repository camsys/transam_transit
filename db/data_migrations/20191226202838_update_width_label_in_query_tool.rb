class UpdateWidthLabelInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'width')&.update!(label: 'Width (Infrastructure Primary Asset)')
  end
end