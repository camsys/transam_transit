RSpec.configure do |config|

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events organizations policies policy_items]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
