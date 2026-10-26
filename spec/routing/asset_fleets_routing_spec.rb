require "rails_helper"

# TTPLAT-3118: transit's runner route must survive TTPLAT-3091, which removes
# core's policies#runner (a different route with a similar name).
RSpec.describe AssetFleetsController, type: :routing do
  it 'routes GET /asset_fleets/runner to asset_fleets#runner' do
    expect(:get => '/asset_fleets/runner').to route_to('asset_fleets#runner')
  end
end
