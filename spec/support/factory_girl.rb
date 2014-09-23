RSpec.configure do |config|
  # additional factory_girl configuration
  
  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events organizations]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      #FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
