require 'rails_helper'

RSpec.describe TransitAgency, :type => :model do

  let(:test_agency) { create(:transit_operator) }

  # Revenue vehicle creation runs through PolicyAware's check_policy_rule callback, which needs
  # a policy chain for the owning organization (see revenue_vehicle_spec.rb's before(:each)).
  before(:each) do
    parent_policy = create(:parent_policy)
    create(:policy, :organization => test_agency, :parent => parent_policy)
  end

  it '.has_assets? works as expected' do
    create(:revenue_vehicle, organization: test_agency)
    expect(test_agency.has_assets?).to eql(true)
  end

  it '.asset_count works as expected' do
    create(:revenue_vehicle, organization: test_agency)
    expect(test_agency.asset_count).to eql(1)
    create(:revenue_vehicle, organization: test_agency, serial_number: 'ABCDEFGHJKLMNPRST')

    expect(test_agency.asset_count).to eql(2)
  end

  it '.is_typed? works as expected', :skip do
    # generic organization
    expect(Organization.new(:organization_type_id => 1).is_typed?).to eql(false)
    # typed organization
    expect(test_agency.is_typed?).to eql(true)
  end

end
