class CreateNtdReports < ActiveRecord::Migration[5.2]
  def change
    create_table :ntd_reports do |t|
      t.string    :object_key,            :limit => 12, :null => false
      t.references :ntd_form
      t.text       :processing_log
      t.string     :state
      t.integer    :created_by_id

      t.timestamps
    end

    rename_column :ntd_facilities, :ntd_form_id, :ntd_report_id
    rename_column :ntd_revenue_vehicle_fleets, :ntd_form_id, :ntd_report_id
    rename_column :ntd_service_vehicle_fleets, :ntd_form_id, :ntd_report_id
  end
end
