require 'rails_helper'

RSpec.describe FtaFacilityType, :type => :model do

  let(:test_type) { FtaFacilityType.first }
  let(:test_subtype) { create(:asset_subtype) }

  describe '#search' do
    it 'exact' do
      expect(FtaFacilityType.search(test_type.description)).to eq(test_type)
    end
    it 'partial' do
      expect(FtaFacilityType.search(test_type.description[0..1], false)).to eq(test_type)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end

  describe 'asset_subtype' do
    it 'can have associated asset_subtypes' do
      test_type.asset_subtypes << test_subtype
      expect(test_type.asset_subtypes.first).to eq(test_subtype)
    end
  end
end
