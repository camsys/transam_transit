require 'rails_helper'

RSpec.describe AssetServiceLifeReport, :type => :report do
  let(:test_agency) { create(:transit_operator) }

  it 'calculates the total number of assets' do
    @organization = create(:organization)
    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => AssetSubtype.first)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => AssetSubtype.first)

    bus_a = create(:bus,
                   {:organization => @organization,
                    :asset_type => AssetType.first,
                    :asset_subtype => AssetSubtype.first,
                    :serial_number => "bus_a",
                    :reported_condition_rating => 5.0})

    bus_b = create(:bus,
                  {:organization => @organization,
                   :asset_type => AssetType.first,
                   :asset_subtype => AssetSubtype.first,
                   :serial_number => "bus_b",
                   :reported_condition_rating => 5.0})

    test_asset_subtype = Asset.new_asset(bus_a.asset_subtype)
    test_asset_type_id = test_asset_subtype.asset_type_id
    test_asset_subtype_id = test_asset_subtype.asset_subtype_id

    assets = [bus_a, bus_b]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => test_asset_type_id,
                                                  :asset_subtype_id => test_asset_subtype_id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_assets = report[:data].last[2]

    expect(total_assets).to eq(assets.size)
  end

    # it 'calculates the number of assets past policy's ESL condition threshold' do
    #
    # end
end