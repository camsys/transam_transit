class AddRtaApiCredentialsToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :rta_client_id, :string
    add_column :organizations, :rta_client_secret, :string
    add_column :organizations, :rta_tenant_id, :string
  end
end
