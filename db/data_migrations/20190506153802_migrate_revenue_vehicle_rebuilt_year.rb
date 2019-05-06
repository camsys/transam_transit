class MigrateRevenueVehicleRebuiltYear < ActiveRecord::DataMigration
  def up
    RehabilitationUpdateEvent.where(Arel.sql("extended_useful_life_months >= 48")).each do |r|
      # trigger update_asset callback to update callback's rebuilt_year
      r.update_attribute(:extended_useful_life_months, r.extended_useful_life_months)
    end
  end
end