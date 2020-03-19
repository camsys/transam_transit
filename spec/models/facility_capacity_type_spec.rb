require 'rails_helper'

RSpec.describe FacilityCapacityType, :type => :model do

  let(:test_type) { FacilityCapacityType.first }

  describe '#search' do
    it 'exact' do
      expect(FacilityCapacityType.search(test_type.description)).to eq(test_type)
    end
    it 'partial' do
      expect(FacilityCapacityType.search(test_type.description[0..1], false)).to eq(test_type)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end

  it 'responds to api_json' do
    expect(test_type).to respond_to(:api_json)
  end
end
