class AddOrgServiceProviderTypeJoinTable < ActiveRecord::Migration
  def change
    create_join_table :organizations, :service_provider_types do |t|
      t.index :organization_id, :name => :organization_spt_idx1
      t.index :service_provider_type_id, :name => :organization_spt_idx2
    end
  end
end
