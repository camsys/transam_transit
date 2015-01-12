class AddPcntCapitalResponsibility < ActiveRecord::Migration
  def change
    add_column :assets, :pcnt_capital_responsibility, :integer, :after => :manufacture_year
  end
end
