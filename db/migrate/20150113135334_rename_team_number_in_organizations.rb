class RenameTeamNumberInOrganizations < ActiveRecord::Migration
  def change
    rename_column :organizations, :team_number, :ntd_id_number
    change_column :organizations, :ntd_id_number, :string, :limit => 4, :null => true
  end
end
