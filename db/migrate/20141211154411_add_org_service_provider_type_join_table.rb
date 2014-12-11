class AddOrgServiceProviderTypeJoinTable < ActiveRecord::Migration
  def change
    create_join_table :organizations, :service_provider_types do |t|
      t.index :organization_id
      t.index :service_provider_type_id
    end
  end
end
