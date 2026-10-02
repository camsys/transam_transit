require "rails_helper"

RSpec.describe TransitAssetsController, type: :controller do
  
  let(:admin) { create(:admin) }
  
  #Handle requirements for creating a revenue vehicle
  before(:each) do
    @organization = create(:organization)
    # TTPLAT-3072 P1 §2.3: extracted to :parent_policy (see revenue_vehicle_spec.rb).
    parent_policy = create(:parent_policy)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    admin.organization = @organization
    @revenue_vehicle =  create(:revenue_vehicle, organization: @organization) 
    sign_in admin
  end

  describe "GET index" do

    it "returns a 200" do
      get :index, params: {fta_asset_class_code: FtaAssetClass.first.code}
      expect(response).to have_http_status(200)
    end

  end
end
