require 'rails_helper'

RSpec.describe FtaModeType, :type => :model do

  let(:test_type) { FtaModeType.first }

  describe '#search' do
    it 'exact' do
      expect(FtaModeType.search(test_type.description)).to eq(test_type)
    end
    it 'partial' do
      expect(FtaModeType.search(test_type.description[0..1], false)).to eq(test_type)
    end
  end

  it '.to_s' do
    expect(test_type.to_s).to eq("#{test_type.code}-#{test_type.name}")
  end
end
