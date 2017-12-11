$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transam_transit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transam_transit"
  s.version     = TransamTransit::VERSION
  s.authors     = ["Julian Ray"]
  s.email       = ["jray@camsys.com"]
  s.homepage    = "http://www.camsys.com"
  s.summary     = "TransAM Asset Management for Transit"
  s.description = "TransAM Asset Management for Transit"
  s.license     = "MIT"

  s.metadata = { "load_order" => "10" }

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '~> 4.2.7.1'
  s.add_dependency 'paper_trail'
  s.add_dependency 'awesome_nested_set'

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "codacy-coverage"
  s.add_development_dependency "simplecov"
  
end
