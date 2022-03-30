class CreateRtaOrgCredentials < ActiveRecord::Migration[5.2]
  def up
    create_table :rta_org_credentials do |t|
      t.references :organization
      t.string :rta_client_id
      t.string :rta_client_secret
      t.string :rta_tenant_id
      t.string :name
      t.timestamps
    end

    Organization.where.not(rta_client_id: nil, rta_client_secret: nil, rta_tenant_id: nil). each do |o|
      RtaOrgCredential.create(organization: o, rta_client_id: o.rta_client_id, rta_client_secret: o.rta_client_secret, rta_tenant_id: o.rta_tenant_id, name: o.short_name)
    end

    remove_column :organizations, :rta_client_id
    remove_column :organizations, :rta_client_secret
    remove_column :organizations, :rta_tenant_id
  end

  def down
    add_column :organizations, :rta_client_id, :string
    add_column :organizations, :rta_client_secret, :string
    add_column :organizations, :rta_tenant_id, :string

    RtaOrgCredential.each do |c|
      unless c.organization.rta_client_id
        c.organization.update(rta_client_id: c.rta_client_id, rta_client_secret: c.rta_client_secret, rta_tenant_id: c.rta_tenant_id)
      end
    end

    drop_table :rta_org_credentials
  end
end
