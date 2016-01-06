require 'rails_helper'

RSpec.describe TransitAgency, :type => :model do

  let(:test_agency) { create(:transit_agency) }

  it '.has_assets? works as expected' do
    bus = build(:bus, organization_id: test_agency.id)
    test_agency.assets << bus
    expect(test_agency.has_assets?).to eql(true)
  end

  it '.asset_count works as expected' do
    bus1 = create(:bus, organization_id: test_agency.id)
    test_agency.assets << bus1
    expect(test_agency.asset_count).to eql(1)
    bus2 = create(:bus, organization_id: test_agency.id, serial_number: 'abcdefgh982347')
    test_agency.assets << bus2

    expect(test_agency.asset_count).to eql(2)
  end

  it '.is_typed? works as expected', :skip do
    # generic organization
    expect(Organization.new(:organization_type_id => 1).is_typed?).to eql(false)
    # typed organization
    expect(test_agency.is_typed?).to eql(true)
  end

end
