require 'rails_helper'

RSpec.describe AssetServiceLifeReport, :type => :report do

  before(:each) do
    @organization = create(:organization)

    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => AssetSubtype.first)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => AssetSubtype.first)

    # @min_service_life_months = parent_policy.policy_asset_subtype_rules.first.min_service_life_months
  end

  it 'calculates the total number of assets' do
    bus_a = create(:bus,
                   {:organization => @organization,
                    :asset_type => AssetType.first,
                    :asset_subtype => AssetSubtype.first,
                    :serial_number => "bus_a"})

    bus_b = create(:bus,
                  {:organization => @organization,
                   :asset_type => AssetType.first,
                   :asset_subtype => AssetSubtype.first,
                   :serial_number => "bus_b"})

    assets = [bus_a, bus_b]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_assets = report[:data].last[2]

    expect(total_assets).to eq(assets.size)
  end

  it 'calculates the number of assets past policy\'s ESL condition threshold' do
    above_threshold_bus = create(:bus,
                   {:organization => @organization,
                    :asset_type => AssetType.first,
                    :asset_subtype => AssetSubtype.first,
                    :serial_number => "above_threshold_bus",
                    :reported_condition_rating => 5.0})

    below_threshold_bus_a = create(:bus,
                   {:organization => @organization,
                    :asset_type => AssetType.first,
                    :asset_subtype => AssetSubtype.first,
                    :serial_number => "below_threshold_bus_a",
                    :reported_condition_rating => 1.0})

    below_threshold_bus_b = create(:bus,
                   {:organization => @organization,
                    :asset_type => AssetType.first,
                    :asset_subtype => AssetSubtype.first,
                    :serial_number => "below_threshold_bus_b",
                    :reported_condition_rating => 1.0})

    assets = [above_threshold_bus, below_threshold_bus_a, below_threshold_bus_b]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_past_term_threshold = report[:data].last[7]

    expect(total_past_term_threshold ).to eq(2)

  end

  it 'calculates the number of assets past policy\s ESL age threshold' do
    above_threshold_bus = create(:bus,
                                 {:organization => @organization,
                                  :asset_type => AssetType.first,
                                  :asset_subtype => AssetSubtype.first,
                                  :serial_number => "above_threshold_bus",
                                  :in_service_date => Date.today - 13.years})

    #TODO: What if it's exactly 144 months ago? (12 years)

    assets = [above_threshold_bus]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_past_esl_months = report[:data].last[3]

    expect(total_past_esl_months).to eq(1)
  end
end