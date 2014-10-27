class AddGrantTables < ActiveRecord::Migration
  def change

    create_table :grant_purchases do |t|
      t.references  :asset,               :null => :false
      t.references  :grant,               :null => :false
      t.integer     :pcnt_purchase_cost,  :null => :false
      t.timestamps
    end

    add_index :grant_purchases,   [:asset_id, :grant_id],      :name => :grant_purchases_idx1

    create_table :grants do |t|
      t.string      :object_key,      :limit => 12, :null => :false
      t.references  :organization,                  :null => :false
      t.references  :funding_source,                :null => :false
      t.integer     :fy_year,                       :null => :false
      t.string      :grant_number,    :limit => 32, :null => :false
      t.integer     :amount
      t.timestamps
    end

    add_index :grants,   :object_key,           :name => :grants_idx1
    add_index :grants,   :organization_id,      :name => :grants_idx2
    add_index :grants,   :fy_year,              :name => :grants_idx3
    add_index :grants,   :funding_source_id,    :name => :grants_idx4
    
  end
end

