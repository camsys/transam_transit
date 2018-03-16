require 'rails_helper'
require 'pp'

RSpec.describe AssetServiceLifeReport, :type => :report do
  let(:test_agency) { create(:transit_operator) }

  it 'calculates correct number of assets past condition' do

    bus = build(:bus, organization_id: test_agency.id, reported_condition_rating: 3.0)

    ap bus

    test_agency.assets << bus

    assets = [bus]
    organization_id_list = assets.map{|asset| asset.organization_id}

    report = AssetServiceLifeReport.new

    expect(report.get_data(organization_id_list, {})[:data][0][3]).to eq(0)
  end

end

# car1.reported_condition_rating = 1
# car2.reported_condition_rating = 2
# car3.reported_condition_rating = 3
#
# if policies.condition_threshold = 2.5
#   past_esl_condition should equal 2
