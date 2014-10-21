RSpec.configure do |config|
  # additional factory_girl configuration

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events asset_event_types asset_subtypes asset_types organizations organization_types policies policy_items]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      #FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
