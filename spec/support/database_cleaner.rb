RSpec.configure do |config|

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events organizations policies policy_asset_type_rules policy_asset_subtype_rules vendors]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
