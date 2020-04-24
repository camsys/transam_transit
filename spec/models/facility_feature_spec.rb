require 'rails_helper'

RSpec.describe FacilityFeature, :type => :model do

  let(:test_type) { FacilityFeature.first }

  describe '#search' do
    it 'exact' do
      expect(FacilityFeature.search(test_type.description)).to eq(test_type)
    end
    it 'partial' do
      expect(FacilityFeature.search(test_type.description[0..1], false)).to eq(test_type)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq("#{test_type.code}-#{test_type.name}")
  end

  it 'responds to api_json' do
    expect(test_type).to respond_to(:api_json)
  end
end
