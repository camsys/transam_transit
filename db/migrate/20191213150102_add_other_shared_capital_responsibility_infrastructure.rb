class AddOtherSharedCapitalResponsibilityInfrastructure < ActiveRecord::Migration[5.2]
  def change
    add_column :infrastructures, :other_shared_capital_responsibility, :string, after: :shared_capital_responsibility_organization_id
  end
end
