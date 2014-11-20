class FixOrganizationsModel < ActiveRecord::Migration
  def change
    
    remove_column :organizations, :urban_rural_type_id  

    create_join_table :organizations, :fta_mode_types
    
    add_index :fta_mode_types_organizations,   [:organization_id, :fta_mode_type_id], :name => :fta_mode_types_organizations_idx1

    drop_table :organizations_service_types
    drop_table :mpms_projects
    drop_table :service_types

  end
end
