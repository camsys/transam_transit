class UpdateInfrastructureWeightLabelInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'infrastructure_weight')&.update!(label: 'Weight (Infrastructure Component)')
  end
end