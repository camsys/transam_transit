require 'rails_helper'

RSpec.describe AssetServiceLifeReport, :type => :report do
  let(:test_agency) { create(:transit_operator) }

  it 'calculates correct number of assets past ESL condition threshold' do

    test_organization = create(:organization)

    bus = build(:bus, organization_id: test_agency.id, reported_condition_rating: 1.0)
    test_asset_subtype = Asset.new_asset(bus.asset_subtype)

    test_policy = create(:policy)


    assets = [bus]
    organization_id_list = assets.map{|asset| asset.organization_id}

    report = AssetServiceLifeReport.new.get_data({organization_id_list => organization_id_list}, {test_organization => :organization, test_asset_subtype => :asset_subtype, test_policy => :policy})

    total_assets_past_condition = report[:data][0][3]

    expect(total_assets_past_condition).to eq(1)

  end

end

# car1.reported_condition_rating = 1
# car2.reported_condition_rating = 2
# car3.reported_condition_rating = 3
#
# if policies.condition_threshold = 2.5
# past_esl_condition should equal 2
