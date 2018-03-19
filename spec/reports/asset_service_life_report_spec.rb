require 'rails_helper'

RSpec.describe AssetServiceLifeReport, :type => :report do
  let(:test_agency) { create(:transit_operator) }

  it 'calculates correct number of assets past ESL condition threshold' do
    bus = build(:bus, organization_id: test_agency.id, reported_condition_rating: 5.0)
    test_asset_subtype = Asset.new_asset(bus.asset_subtype)

    test_asset_type_id = test_asset_subtype.asset_type_id
    test_asset_subtype_id = test_asset_subtype.asset_subtype_id

    assets = [bus]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => test_asset_type_id,
                                                  :asset_subtype_id => test_asset_subtype_id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_assets_past_condition = report[:data][0][3]

    expect(total_assets_past_condition).to eq(0)
  end
end