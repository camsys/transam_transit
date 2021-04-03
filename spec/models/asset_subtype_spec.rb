require 'rails_helper'

RSpec.describe AssetSubtype, :type => :model do

  let(:test_subtype) { create(:asset_subtype) }
  let(:test_type1) { FtaVehicleType.first }
  let(:test_type2) { FtaVehicleType.second }

  describe 'associations' do
    it 'has fta_types' do
      expect(test_subtype).to respond_to(:fta_types)
    end
  end

  describe 'fta_types' do
    it 'can be associated with fta types' do
      test_type1.asset_subtypes << test_subtype
      expect(test_subtype.fta_types).to eq([test_type1])
      test_type2.asset_subtypes << test_subtype
      test_subtype.reload
      expect(test_subtype.fta_types.count).to be 2
    end
  end
end
