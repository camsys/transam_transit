require 'rails_helper'

RSpec.describe ServiceProviderType, :type => :model do

  let(:test_type) { ServiceProviderType.first }

  it '.to_s' do
    expect(test_type.to_s).to eq("#{test_type.code}-#{test_type.name}")
  end
end
