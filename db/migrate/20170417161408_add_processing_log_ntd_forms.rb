class AddProcessingLogNtdForms < ActiveRecord::Migration[4.2]
  def change
    add_column :ntd_forms, :processing_log, :text
  end
end
