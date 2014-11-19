class AddEquipmentClass < ActiveRecord::Migration
  def change
    add_column    :assets, :quantity,     :integer,                 :after => :facility_capacity_type_id
    add_column    :assets, :quantity_units, :string, :limit => 16,  :after => :quantity
  end
end
