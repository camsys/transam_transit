class AddPlanningPartnersOrganizations < ActiveRecord::Migration[4.2]
  def change
    create_table :planning_partners_organizations do |t|
      t.integer :planning_partner_id, index: true
      t.integer :organization_id, index: true
    end
  end
end
