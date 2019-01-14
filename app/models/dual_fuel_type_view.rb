class DualFuelTypeView < ActiveRecord::Base
  self.table_name = :dual_fuel_type_view
  self.primary_key = :id

  def readonly?
    true
  end

  # All types that are available
  scope :active, -> { where(:active => true) }

end
