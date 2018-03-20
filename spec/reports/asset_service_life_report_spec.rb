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

  it 'calculates the number of assets past policy\'s ESL age threshold' do
    within_esl_bus = create(:bus,
                                 {:organization => @organization,
                                  :asset_type => AssetType.first,
                                  :asset_subtype => AssetSubtype.first,
                                  :serial_number => "within_esl_bus",
                                  :in_service_date => Date.today - 5.years})

    past_esl_bus_a = create(:bus,
                          {:organization => @organization,
                           :asset_type => AssetType.first,
                           :asset_subtype => AssetSubtype.first,
                           :serial_number => "past_esl_bus_a",
                           :in_service_date => Date.today - 13.years})

    past_esl_bus_b = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_b",
                             :in_service_date => Date.today - 14.years})

    assets = [within_esl_bus, past_esl_bus_a, past_esl_bus_b]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_past_esl_months = report[:data].last[3]

    expect(total_past_esl_months).to eq(2)
  end

  it 'filters the number of assets past policy\'s ESL age threshold' do
    past_esl_bus_a = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_a",
                             :in_service_date => Date.today - 13.years}) #12 months past policy

    past_esl_bus_b = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_b",
                             :in_service_date => Date.today - 14.years}) #24 months past policy

    past_esl_bus_c = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_c",
                             :in_service_date => Date.today - 15.years}) #36 months past policy

    past_esl_bus_d = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_d",
                             :in_service_date => Date.today - 16.years}) #48 months past policy

    assets = [past_esl_bus_a, past_esl_bus_b, past_esl_bus_c, past_esl_bus_d]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 24
    test_months_past_esl_max = 36

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_past_esl_months = report[:data].last[3]

    expect(total_past_esl_months).to eq(2)
  end

  it 'calculates the number of assets past policy\'s ESL mileage threshold' do
    within_esl_bus = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "within_esl_bus",
                             :reported_mileage => 250000})

    past_esl_bus_a = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_a",
                             :reported_mileage => 600000})

    past_esl_bus_b = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_b",
                             :reported_mileage => 750000})

    assets = [within_esl_bus, past_esl_bus_a, past_esl_bus_b]
    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_past_esl_miles = report[:data].last[5]

    expect(total_past_esl_miles).to eq(2)
  end

  it 'calculates the number of assets past policy\'s ESL mileage threshold when assets have different policies' do
    @organization_b = create(:organization)
    parent_policy_b = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy_b, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy_b, :asset_subtype => AssetSubtype.first)
    policy_b = create(:policy, :organization => @organization_b, :parent => parent_policy_b)
    create(:policy_asset_type_rule, :policy => policy_b, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => policy_b, :asset_subtype => AssetSubtype.first, :min_service_life_miles => 700000)

    within_esl_bus_policy_a = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "within_esl_bus_policy_a",
                             :reported_mileage => 400000})

    past_esl_bus_policy_a = create(:bus,
                            {:organization => @organization,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_policy_a",
                             :reported_mileage => 600000})

    within_esl_bus_policy_b = create(:bus,
                                     {:organization => @organization_b,
                                      :asset_type => AssetType.first,
                                      :asset_subtype => AssetSubtype.first,
                                      :serial_number => "within_esl_bus_policy_b",
                                      :reported_mileage => 600000})

    past_esl_bus_policy_b = create(:bus,
                            {:organization => @organization_b,
                             :asset_type => AssetType.first,
                             :asset_subtype => AssetSubtype.first,
                             :serial_number => "past_esl_bus_policy_b",
                             :reported_mileage => 800000})


    # ap @organization.get_policy().policy_asset_subtype_rules().first[:min_service_life_miles]
    # ap @organization_b.get_policy().policy_asset_subtype_rules().first[:min_service_life_miles]
    # ap within_esl_bus_policy_a[:reported_mileage]
    # ap past_esl_bus_policy_a[:reported_mileage]
    # ap within_esl_bus_policy_b[:reported_mileage]
    # ap past_esl_bus_policy_b[:reported_mileage]

    assets = [within_esl_bus_policy_a, past_esl_bus_policy_a, within_esl_bus_policy_b, past_esl_bus_policy_b]

    organization_id_list = assets.map{|asset| asset.organization_id}

    test_months_past_esl_min = 0
    test_months_past_esl_max = 0

    report = AssetServiceLifeReport.new.get_data(organization_id_list,
                                                 {:asset_type_id => AssetType.first.id,
                                                  :asset_subtype_id => AssetSubtype.first.id,
                                                  :months_past_esl_min => test_months_past_esl_min,
                                                  :months_past_esl_max => test_months_past_esl_max})

    total_past_esl_miles = report[:data].last[5]

    expect(total_past_esl_miles).to eq(2)
  end
end