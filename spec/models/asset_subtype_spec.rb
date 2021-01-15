require 'rails_helper'

RSpec.describe AssetSubtype, :type => :model do

  let(:test_subtype) { create(:asset_subtype) }
  let(:test_type) { FtaVehicleType.first }

  describe 'associations' do
    it 'has an asset type' do
      expect(test_subtype).to belong_to(:fta_type)
    end
  end

  describe 'fta_type' do
    it 'can be associated with an fta type' do
      test_subtype.fta_type = test_type
      test_subtype.save
      test_subtype.reload
      expect(test_subtype.fta_type).to eq(test_type)
    end
  end
end
