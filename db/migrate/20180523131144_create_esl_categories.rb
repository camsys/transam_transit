class CreateEslCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :esl_categories do |t|
      t.string :name
      t.string :class_name
      t.boolean :active
    end
  end
end
