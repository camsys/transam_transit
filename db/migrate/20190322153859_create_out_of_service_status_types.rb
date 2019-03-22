class CreateOutOfServiceStatusTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :out_of_service_status_types do |t|
      t.string :name
      t.string :description
      t.boolean :active
    end

    add_reference :asset_events, :out_of_service_status_type, after: :service_status_type_id
  end
end
