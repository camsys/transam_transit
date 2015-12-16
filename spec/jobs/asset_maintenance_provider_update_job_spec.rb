require 'rails_helper'

RSpec.describe AssetMaintenanceProviderUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it '.run' do
    test_asset = create(:buslike_asset, :maintenance_provider_type => create(:maintenance_provider_type))
    test_event = test_asset.maintenance_provider_updates.create!(attributes_for(:maintenance_provider_update_event))
    AssetMaintenanceUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.maintenance_provider_type).to eq(test_event.maintenance_provider_type)
  end
end
