class RemoveLimitNtdIdNumberOrganizations < ActiveRecord::Migration
  def change
    change_column :organizations, :ntd_id_number, :string, :limit => nil
  end
end
