class RemoveLimitNtdIdNumberOrganizations < ActiveRecord::Migration[4.2]
  def change
    change_column :organizations, :ntd_id_number, :string, :limit => nil
  end
end
