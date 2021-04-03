require 'rails_helper'

RSpec.describe TransitAsset, type: :model do 

  let (:old_class) { FtaAssetClass.find_by(code: "bus") }
  let (:new_class) { FtaAssetClass.find_by(code: "rail_car") }
  let (:old_type) { FtaVehicleType.find(10) }
  let (:new_type) { FtaSupportVehicleType.find(1) }
  let (:old_subtype) { AssetSubtype.find(1) }
  let (:new_subtype) { AssetSubtype.find(2) }
  let (:user) { create(:normal_user) }
  
  it { should respond_to :service_status_name, :service_status }

  # Handle PolicyAware requirements
  before(:each) do
    organization = create(:organization)
    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => old_subtype)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => new_subtype)
    policy = create(:policy, :organization => organization, :parent => parent_policy)
    @transit_asset =  create(:revenue_vehicle, organization: organization)
    create(:system_user)
  end
  
  describe 'asset type info log' do
    it 'should handle no changes' do
      expect(@transit_asset.update_type_info).to be nil
      expect(@transit_asset.report_logged_type_info).to include(old_class.to_s, old_type.to_s, old_subtype.to_s)
      expect(@transit_asset.revert_type_info).to be false
    end
    
    it 'should handle a single change' do
      expect(@transit_asset.update_type_info(fta_class: new_class, fta_type: new_type, subtype: new_subtype)).to be_an(AssetTypeInfoLog)
      @transit_asset.reload
      expect(@transit_asset.fta_asset_class).to eq new_class
      expect(@transit_asset.fta_type).to eq new_type
      expect(@transit_asset.asset_subtype).to eq new_subtype
      expect(@transit_asset.report_logged_type_info).to include(TransamHelper.system_user.to_s)
      expect(@transit_asset.report_logged_type_info).to include(new_class.to_s, new_type.to_s, new_subtype.to_s)
      expect(@transit_asset.revert_type_info).to be true
      expect(@transit_asset.fta_asset_class).to eq old_class
      expect(@transit_asset.fta_type).to eq old_type
      expect(@transit_asset.asset_subtype).to eq old_subtype
      expect(@transit_asset.report_logged_type_info).to include(old_class.to_s, old_type.to_s, old_subtype.to_s)
      expect(@transit_asset.report_logged_type_info).to_not include(new_class.to_s, new_type.to_s, new_subtype.to_s)
      expect(@transit_asset.revert_type_info).to be false
    end
    
    it 'should handle multiple changes' do
      expect(@transit_asset.update_type_info(fta_class: new_class)).to be_an(AssetTypeInfoLog)
      sleep 1                   # avoid having same timestamps on logs
      expect(@transit_asset.update_type_info(fta_type: new_type)).to be_an(AssetTypeInfoLog)
      sleep 1                   # avoid having same timestamps on logs
      info_log = @transit_asset.update_type_info(subtype: new_subtype, user: user)
      expect(info_log).to be_an(AssetTypeInfoLog)
      expect(info_log.creator).to eq(user)

      @transit_asset.reload
      expect(@transit_asset.fta_asset_class).to eq new_class
      expect(@transit_asset.fta_type).to eq new_type
      expect(@transit_asset.asset_subtype).to eq new_subtype

      expect(@transit_asset.revert_type_info).to be true
      expect(@transit_asset.fta_asset_class).to eq new_class
      expect(@transit_asset.fta_type).to eq new_type
      expect(@transit_asset.asset_subtype).to eq old_subtype

      expect(@transit_asset.revert_type_info).to be true
      expect(@transit_asset.fta_asset_class).to eq new_class
      expect(@transit_asset.fta_type).to eq old_type
      expect(@transit_asset.asset_subtype).to eq old_subtype

      expect(@transit_asset.revert_type_info).to be true
      expect(@transit_asset.fta_asset_class).to eq old_class
      expect(@transit_asset.fta_type).to eq old_type
      expect(@transit_asset.asset_subtype).to eq old_subtype
      expect(@transit_asset.report_logged_type_info).to include(old_class.to_s, old_type.to_s, old_subtype.to_s)
      expect(@transit_asset.report_logged_type_info).to_not include(new_class.to_s, new_type.to_s, new_subtype.to_s)
      expect(@transit_asset.revert_type_info).to be false
    end
  end
    
end
