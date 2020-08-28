require "rails_helper"

RSpec.describe TransitAssetsController, type: :controller do
  
  let(:admin) { create(:admin) }
  
  #Handle requirements for creating a revenue vehicle
  before(:each) do
    @organization = create(:organization)
    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => AssetSubtype.first)
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
