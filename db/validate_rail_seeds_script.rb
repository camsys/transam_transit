# Validates that engine rail seed data has loaded as expected
# Added to the dynamically generated tmp/validate_seeds_data.rb file
# Via the transam_{engine_name}:validate_engine_seeds rake task
# Which should only be called from an app-level validate_engine_seeds rake task

# Only added if the app-level environment has rail assets configured

puts "      === Validating data from db/seeds/rail.seeds.rb ==="
puts "        asset_types"
asset_types.each do |row|
  row_does_not_exist = AssetType.find_by(row).nil?
  row_is_not_unique = AssetType.where(row).count > 1

  puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
  puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique

  # Skip id check since this is a merge_table
end

puts "        asset_subtypes"
asset_subtypes.each do |row|
  filtered_row = row.except(:belongs_to, :type)
  filtered_row[:asset_type] = AssetType.where(:name => row[:type]).first
  row_does_not_exist = AssetSubtype.find_by(filtered_row).nil?
  row_is_not_unique = AssetSubtype.where(filtered_row).count > 1
  asset_type_not_found = filtered_row[:asset_type].nil?

  puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
  puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
  puts "          #{row.inspect} does not associate with an asset_type in this environment. Searched AssetType by name, using: #{row[:type]}." if asset_type_not_found

  # Skip id check since this is a merge_table
end
