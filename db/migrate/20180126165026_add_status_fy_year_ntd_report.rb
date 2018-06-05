class AddStatusFyYearNtdReport < ActiveRecord::Migration[4.2]
  def change
    remove_column :asset_fleets, :active
    #remove_column :ntd_forms, :start_date
    #remove_column :ntd_forms, :end_date
  end
end
