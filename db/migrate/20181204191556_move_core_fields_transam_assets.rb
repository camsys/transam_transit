class MoveCoreFieldsTransamAssets < ActiveRecord::Migration[5.2]
  def change

    change_table :transit_assets do |t|
      t.references  :operator, after: :warranty_date
      t.string      :other_operator, after: :operator_id
      t.string      :title_number, after: :other_operator
      t.references  :title_ownership_organization, after: :title_number
      t.string      :other_title_ownership_organization, after: :title_ownership_organization_id
      t.references  :lienholder, after: :other_title_ownership_organization
      t.string      :other_lienholder, after: :lienholder_id

    end
  end
end
