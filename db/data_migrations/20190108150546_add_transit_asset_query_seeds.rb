class AddTransitAssetQuerySeeds < ActiveRecord::DataMigration
  def up
    require TransamTransit::Engine.root.join('db', 'seeds', 'asset_query_seeds.rb')
  end
end