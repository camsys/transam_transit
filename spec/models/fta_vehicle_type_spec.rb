require 'rails_helper'

RSpec.describe FtaVehicleType, :type => :model do

  let(:test_type) { FtaVehicleType.first }

  describe '#search' do
    it 'exact' do
      expect(FtaVehicleType.search(test_type.description)).to eq(test_type)
    end
    it 'partial' do
      expect(FtaVehicleType.search(test_type.description[0..1], false)).to eq(test_type)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq("#{test_type.code}-#{test_type.name}")
  end
end
