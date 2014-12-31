load_rail_items = ENV["LOAD_RAIL_ITEMS"]
#because Figaro will only store strings
load_rail_items ||= "true"
if load_rail_items == "true"

	is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'mysql2')

	asset_subtypes = [
		{:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Commuter Rail Station', :image => 'commuter_rail_station.png', :description => 'Commuter Rail Station'},
		{:active => 1, :belongs_to => 'asset_type',  :type => 'Maintenance Equipment',  :name => 'Rail Maintenance Equipment',      :image => 'pickup_truck.png',     :description => 'Rail Maintenance Equipment'},
		{:active => 1, :belongs_to => 'asset_type',  :type => 'Signals/Signs',  :name => 'Train Control/Signal System',    :image => 'pickup_truck.png',     :description => 'Train Control/Signal Systems'}
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
		{:active => 1, :policy_id => 1, :asset_subtype => 'Commuter Rail Station', :max_service_life_months => 12*25, :replacement_cost => 1000000,  :pcnt_residual_value => 0, :replacement_ali_code => '11.32.02', :rehabilitation_ali_code => '11.34.02', :rehabilitation_cost => 100000, :extended_service_life_months => 12*4, :extended_service_life_miles => 0},
		{:active => 1, :policy_id => 1, :asset_subtype => 'Rail Maintenance Equipment',     :max_service_life_months => 50,  :replacement_ali_code => '12.42.06',  :rehabilitation_ali_code => '12.44.06', :max_service_life_miles => 0,  :replacement_cost => 0, :pcnt_residual_value => 0, :rehabilitation_cost => 0, :extended_service_life_months => 12*0, :extended_service_life_miles => 0},
		{:active => 1, :policy_id => 1, :asset_subtype => 'Train Control/Signal System',    :max_service_life_months => 100,  :replacement_ali_code => '11.62.01', :rehabilitation_ali_code => '11.64.01', :max_service_life_miles => 0,  :replacement_cost => 0, :pcnt_residual_value => 0, :rehabilitation_cost => 0, :extended_service_life_months => 12*0, :extended_service_life_miles => 0}
	]

	policy_items.each do |policy_item|
		asset_subtype = AssetSubtype.find_by(name: policy_item[:asset_subtype])
		PolicyItem.find_or_create_by(:asset_subtype => asset_subtype) do |new_policy_item|
			policy_item.except(:asset_subtype).keys.each do |key|
				new_policy_item[key] = policy_item[key]
			end

			# new_policy_item.active = policy_item[:active]
			# new_policy_item.policy_id = policy_item[:policy_id]
			# new_policy_item.max_service_life_months = policy_item[:max_service_life_months]
			# new_policy_item.replacement_ali_code = policy_item[:replacement_ali_code]
			# new_policy_item.rehabilitation_ali_code = policy_item[:rehabilitation_ali_code]
			# new_policy_item.max_service_life_miles = policy_item[:max_service_life_miles]
			# new_policy_item.replacement_cost = policy_item[:replacement_cost]
			# new_policy_item.pcnt_residual_value = policy_item[:pcnt_residual_value]
			# new_policy_item.rehabilitation_cost = policy_item[:rehabilitation_cost]
			# new_policy_item.extended_service_life_months = policy_item[:extended_service_life_months]
			# new_policy_item.extended_service_life_miles = policy_item[:extended_service_life_miles]
		end
	end

end