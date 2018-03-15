require 'rails_helper'

RSpec.describe AssetServiceLifeReport, :type => :report do
  let(:test_agency) { create(:transit_operator) }

  it "can check equality" do
    two = 2
    expect(two).to eq(2)
  end

  it 'calculates correct number of assets past condition' do

    bus = build(:bus, organization_id: test_agency.id)

    test_agency.assets << bus
    expect(test_agency.has_assets?).to eql(true)

    # organization = build(:organization)
    # asset_a = build(:buslike_asset)
    # report = AssetServiceLifeReport.new
    # asset_a = Asset.new(organization: organization, reported_condition_rating: 1)
    # asset_b = Asset.new(organization: 1, reported_condition_rating: 2)
    # asset_c = Asset.new(organization: 1, reported_condition_rating: 3)
    # assets = [asset_a, asset_b, asset_c]
    assets = [bus]
    organization_id_list = assets.map{|a| a.organization_id}
    p organization_id_list
    expect(report.get_data(organization_id_list, 0).past_esl_date).to eq(2)
  end

end

# car1.reported_condition_rating = 1
# car2.reported_condition_rating = 2
# car3.reported_condition_rating = 3
#
# if policies.condition_threshold = 2.5
#   past_esl_condition should equal 2
