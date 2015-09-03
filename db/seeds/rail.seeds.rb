
  asset_types = [
    {:active => 1, :name => 'Rail Cars',                :description => 'Rail cars and LRVs',         :class_name => 'RailCar',           :map_icon_name => "orangeIcon",   :display_icon_name => "fa fa-subway"},
    {:active => 1, :name => 'Locomotives',              :description => 'Locomotives',                :class_name => 'Locomotive',        :map_icon_name => "redIcon",      :display_icon_name => "fa fa-train"}
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
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Bus Trolley STD', :image => 'light_rail.png',  :description => 'Bus Trolley Std'},
    {:active => 1, :belongs_to => 'asset_type',  :type => 'Rail Cars', :name => 'Bus Trolley Articulated', :image => 'light_rail.png',  :description => 'Bus Trolley Articulated'},

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
