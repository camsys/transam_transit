class ClearOutNtdForms < ActiveRecord::DataMigration
  def up
    NtdForm.destroy_all
  end
end