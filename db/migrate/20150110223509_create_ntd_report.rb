class CreateNtdReport < ActiveRecord::Migration
  def change
    create_table :ntd_forms do |t|
      t.string    :object_key,            :limit => 12, :null => false
      t.integer   :form_id,                             :null => false
      t.integer   :organization_id,                     :null => false
      t.integer   :fy_year,                             :null => false
      t.string    :state,                 :limit => 32, :null => false

      t.string    :reporter_name,         :limit => 64, :null => false
      t.string    :reporter_title,        :limit => 64, :null => false
      t.string    :reporter_department,   :limit => 64, :null => false
      t.string    :reporter_email,        :limit => 128,:null => false
      t.string    :reporter_phone,        :limit => 12, :null => false
      t.string    :reporter_phone_ext,    :limit => 6,  :null => false


      t.integer   :created_by_id,                       :null => false
      t.integer   :updated_by_id,                       :null => false
      t.timestamps
    end

    add_index :ntd_forms, :object_key, :unique => true,  :name => :ntd_forms_idx1
    add_index :ntd_forms, [:organization_id, :fy_year], :name => :ntd_forms_idx2

    create_table :ntd_admin_and_maintenance_facilities do |t|
      t.integer   :ntd_form_id,                         :null => false

      t.string    :name,                  :limit => 64, :null => false
      t.boolean   :part_of_larger_facility
      t.string    :address,               :limit => 128,:null => false
      t.string    :city,                  :limit => 64, :null => false
      t.string    :state,                 :limit => 2,  :null => false
      t.string    :zip,                   :limit => 10, :null => false
      t.float     :latitude
      t.float     :longitude

      t.string    :primary_mode,          :limit => 32, :null => false
      t.string    :facility_type,         :limit => 32, :null => false
      t.integer   :year_built,                          :null => false
      t.integer   :size,                                :null => false
      t.string    :size_type,             :limit => 32, :null => false
      t.integer   :pcnt_capital_responsibility,         :null => false

      t.integer   :estimated_cost,                      :null => false
      t.integer   :estimated_cost_year,                 :null => false

      t.string    :notes,                 :limit => 254

      t.timestamps
    end
    add_index :ntd_admin_and_maintenance_facilities, :ntd_form_id, :name => :ntd_admin_and_maintenance_facilities_idx1

    create_table :ntd_passenger_and_parking_facilities do |t|
      t.integer   :ntd_form_id,                         :null => false

      t.string    :name,                  :limit => 64, :null => false
      t.boolean   :part_of_larger_facility
      t.string    :address,               :limit => 128,:null => false
      t.string    :city,                  :limit => 64, :null => false
      t.string    :state,                 :limit => 2,  :null => false
      t.string    :zip,                   :limit => 10, :null => false
      t.float     :latitude
      t.float     :longitude

      t.string    :primary_mode,          :limit => 32, :null => false
      t.string    :facility_type,         :limit => 32, :null => false
      t.integer   :year_built,                          :null => false
      t.integer   :size,                                :null => false
      t.string    :size_type,             :limit => 32, :null => false

      t.integer   :pcnt_capital_responsibility,         :null => false
      t.integer   :estimated_cost,                      :null => false
      t.integer   :estimated_cost_year,                 :null => false

      t.string    :notes,                 :limit => 254

      t.timestamps
    end
    add_index :ntd_passenger_and_parking_facilities, :ntd_form_id, :name => :ntd_passenger_and_parking_facilities_idx1

    create_table :ntd_service_vehicle_fleets do |t|
      t.integer   :ntd_form_id,                         :null => false

      t.string    :name,                  :limit => 64, :null => false
      t.integer   :size,                                :null => false
      t.string    :vehicle_type,          :limit => 32, :null => false
      t.integer   :manufacture_year,                    :null => false
      t.integer   :avg_expected_years,                  :null => false
      t.integer   :pcnt_capital_responsibility,         :null => false

      t.integer   :estimated_cost,                      :null => false
      t.integer   :estimated_cost_year,                 :null => false

      t.string    :notes,                 :limit => 254

      t.timestamps
    end
    add_index :ntd_service_vehicle_fleets, :ntd_form_id, :name => :ntd_service_vehicle_fleets_idx1

    create_table :ntd_revenue_vehicle_fleets do |t|
      t.integer   :ntd_form_id,                         :null => false

      t.string    :rvi_id,                :limit => 4,  :null => false
      t.integer   :size,                                :null => false
      t.integer   :num_active,                          :null => false
      t.integer   :num_ada_accessible,                  :null => false
      t.integer   :num_emergency_contingency,           :null => false

      t.string    :vehicle_type,          :limit => 32, :null => false
      t.string    :funding_source,        :limit => 32, :null => false
      t.string    :manufacture_code,      :limit => 4,  :null => false
      t.string    :model_number,          :limit => 32, :null => false

      t.integer   :renewal_year,                        :null => false
      t.string    :renewal_type,          :limit => 32, :null => false
      t.integer   :renewal_cost,                        :null => false
      t.integer   :renewal_cost_year,                   :null => false

      t.integer   :replacement_cost,                    :null => false
      t.integer   :replacement_cost_year,               :null => false
      t.boolean   :replacement_cost_parts,              :null => false
      t.boolean   :replacement_cost_warranty,           :null => false

      t.string    :fuel_type,          :limit => 32,    :null => false
      t.integer   :vehicle_length,                      :null => false
      t.integer   :seating_capacity,                    :null => false
      t.integer   :standing_capacity,                   :null => false
      t.integer   :total_active_miles_in_period,        :null => false
      t.integer   :avg_lifetime_active_miles,           :null => false

      t.string    :notes,                 :limit => 254

      t.timestamps
    end

    add_index :ntd_revenue_vehicle_fleets, :ntd_form_id, :name => :ntd_revenue_vehicle_fleets_idx1

  end
end
