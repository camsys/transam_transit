class AddSectionOfLargerFacility < ActiveRecord::Migration
  def change
    add_column :assets, :section_of_larger_facility, :boolean, :after => :facility_size
  end
end
