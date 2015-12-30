require 'rails_helper'

RSpec.describe AssetMaintenanceUpdateJob, :type => :job do

  it '.run' do
    test_asset = create(:buslike_asset)
    test_event = test_asset.maintenance_updates.create!(attributes_for(:maintenance_update_event))
    AssetMaintenanceUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.last_maintenance_date).to eq(Date.today)
  end
end
