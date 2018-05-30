class AddProcessingLogNtdForms < ActiveRecord::Migration
  def change
    add_column :ntd_forms, :processing_log, :text
  end
end
