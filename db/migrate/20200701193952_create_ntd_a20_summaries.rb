class CreateNtdA20Summaries < ActiveRecord::Migration[5.2]
  def change
    create_table :ntd_a20_summaries do |t|
      t.references :ntd_report
      t.references :fta_mode_type
      t.references :fta_service_type
      t.decimal :monthly_total_average_restrictions_length

      t.timestamps
      t.timestamps
    end
  end
end
