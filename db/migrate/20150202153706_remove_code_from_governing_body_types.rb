class RemoveCodeFromGoverningBodyTypes < ActiveRecord::Migration
  def change
    remove_column :governing_body_types, :code
  end
end
