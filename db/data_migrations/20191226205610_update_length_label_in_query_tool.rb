class UpdateLengthLabelInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'length')&.update!(label: 'Length (Infrastructure Primary Asset)')
  end
end