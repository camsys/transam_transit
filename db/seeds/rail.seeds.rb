
  asset_types = [
    {:active => 1, :name => 'Rail Cars',                :description => 'Rail cars and LRVs',         :class_name => 'RailCar',           :map_icon_name => "orangeIcon",   :display_icon_name => "fa travelcon-subway"},
    {:active => 1, :name => 'Locomotives',              :description => 'Locomotives',                :class_name => 'Locomotive',        :map_icon_name => "redIcon",      :display_icon_name => "fa travelcon-train"}
  ]

  puts "  Merging rail asset_types"
  asset_types.each do |asset_type|
    x = AssetType.new(asset_type)
    x.save!
  end

  asset_subtypes = [
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Commuter Rail Station', :image => 'commuter_rail_station.png', :description => 'Commuter Rail Station'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Maintenance Equipment',  :name => 'Rail Maintenance Equipment',      :image => 'pickup_truck.png',     :description => 'Rail Maintenance Equipment'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Signals/Signs',  :name => 'Train Control/Signal System',    :image => 'pickup_truck.png',     :description => 'Train Control/Signal Systems'},

    {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities',  :name => 'Heavy Rail Maintenance Facility',    :image => 'pickup_truck.png',     :description => 'Heavy Rail Maintenance Facility'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities',  :name => 'Light Rail Maintenance Facility',    :image => 'pickup_truck.png',     :description => 'Light Rail Maintenance Facility'},

    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Light Rail Car', :image => 'light_rail.png',  :description => 'Light Rail car'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Heavy Rail Car', :image => 'heavy_rail.png',  :description => 'Heavy Rail car'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Commuter Rail Self Propelled (Elec)', :image => 'light_rail.png',  :description => 'Commuter Rail Self Propelled (Elec)'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Commuter Rail Self Propelled (Diesel)', :image => 'heavy_rail.png',  :description => 'Commuter Rail Self Propelled (Diesel)'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Commuter Rail Car Trailer', :image => 'heavy_rail.png',  :description => 'Commuter Rail Car Trailer'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Incline Railway Car', :image => 'heavy_rail.png',  :description => 'Incline Railway Car'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Cable Car', :image => 'heavy_rail.png',  :description => 'Cable Car'},

    {:active => 1, :belongs_to => 'asset_type',  :type => 'Locomotives', :name => 'Commuter Locomotive Diesel',   :image => 'light_rail.png',  :description => 'Commuter Locomotive (Diesel)'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Locomotives', :name => 'Commuter Locomotive Electric', :image => 'heavy_rail.png',  :description => 'Commuter Locomotive (Electric)'}
  ]

  asset_subtypes.each do |asset_subtype|
    asset_type = AssetType.find_by(name: asset_subtype[:type])
    AssetSubtype.find_or_create_by(:name => asset_subtype[:name]) do |new_asset_subtype|
      new_asset_subtype.active = asset_subtype[:active]
      new_asset_subtype.asset_type = asset_type
      new_asset_subtype.image = asset_subtype[:image]
      new_asset_subtype.description = asset_subtype[:description]
      new_asset_subtype.asset_type = asset_type
    end
  end

  policy_items = [
     # Rail Cars
    {:active => 1, :policy_id => 1, :asset_subtype => 'Light Rail Car',                         :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Heavy Rail Car',                         :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Rail Self Propelled (Elec)',    :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Rail Self Propelled (Diesel)',  :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Rail Car Trailer',              :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Incline Railway Car',                    :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Cable Car',                              :max_service_life_months => 25 * 12, :replacement_cost => 325000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    # Locomotives
    {:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Locomotive Diesel',    :max_service_life_months => 25 * 12, :replacement_cost => 2500000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Locomotive Electric',  :max_service_life_months => 25 * 12, :replacement_cost => 2500000, :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 4 * 12, :extended_service_life_miles => 0},
    # Facilities
    {:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Rail Station',            :max_service_life_months => 12*25, :replacement_cost => 1000000,  :pcnt_residual_value => 0, :replacement_ali_code => '11.32.02', :rehabilitation_ali_code => '11.34.02', :rehabilitation_cost => 100000, :extended_service_life_months => 12*4, :extended_service_life_miles => 0},
    # Equipment
    {:active => 1, :policy_id => 1, :asset_subtype => 'Rail Maintenance Equipment',     :max_service_life_months => 50,  :replacement_ali_code => '12.42.06',  :rehabilitation_ali_code => '12.44.06', :max_service_life_miles => 0,  :replacement_cost => 0, :pcnt_residual_value => 0, :rehabilitation_cost => 0, :extended_service_life_months => 12*0, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Train Control/Signal System',    :max_service_life_months => 100,  :replacement_ali_code => '11.62.01', :rehabilitation_ali_code => '11.64.01', :max_service_life_miles => 0,  :replacement_cost => 0, :pcnt_residual_value => 0, :rehabilitation_cost => 0, :extended_service_life_months => 12*0, :extended_service_life_miles => 0},

    {:active => 1, :policy_id => 1, :asset_subtype => 'Heavy Rail Maintenance Facility', :max_service_life_months => 12*25, :replacement_ali_code => '11.42.02', :rehabilitation_ali_code => '11.44.02', :replacement_cost => 1000000,  :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 12*4, :extended_service_life_miles => 0},
    {:active => 1, :policy_id => 1, :asset_subtype => 'Light Rail Maintenance Facility', :max_service_life_months => 12*25, :replacement_ali_code => '11.42.02', :rehabilitation_ali_code => '11.44.02', :replacement_cost => 1000000,  :pcnt_residual_value => 0, :rehabilitation_cost => 100000, :extended_service_life_months => 12*4, :extended_service_life_miles => 0}
  ]

  policy_items.each do |policy_item|
    asset_subtype = AssetSubtype.find_by(name: policy_item[:asset_subtype])
    PolicyItem.find_or_create_by(:asset_subtype => asset_subtype) do |new_policy_item|
      policy_item.except(:asset_subtype).keys.each do |key|
        new_policy_item[key] = policy_item[key]
      end
    end
  end