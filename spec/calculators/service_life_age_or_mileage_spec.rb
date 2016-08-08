require 'rails_helper'
include FiscalYear

RSpec.describe ServiceLifeAgeOrMileage, :type => :calculator do

  before(:each) do

    @organization = create(:organization)

    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => AssetSubtype.first)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => AssetSubtype.first, :fuel_type_id => 1)

    @test_asset = create(:bus, {:organization => @organization, :asset_type => AssetType.first, :asset_subtype => AssetSubtype.first})

    @mileage_update_event = create(:mileage_update_event, :asset => @test_asset)

  end

  let(:test_calculator) { ServiceLifeAgeOrMileage.new }

  describe '#calculate' do
    it 'calculates if by mileage is min' do
      @mileage_update_event.current_mileage = @test_asset.policy_analyzer.get_min_service_life_miles + 100
      @mileage_update_event.save
      expect(test_calculator.calculate(@test_asset)).to eq(test_calculator.send(:by_mileage,@test_asset))
    end

    it 'calculates if by age is min' do
      # set properties of mileage update event so year returned
      @mileage_update_event.current_mileage = @test_asset.policy_analyzer.get_min_service_life_miles + 100
      @mileage_update_event.event_date = '2999-01-01' # set it impossibly late in the future
      @mileage_update_event.save

      expect(test_calculator.calculate(@test_asset)).to eq(test_calculator.send(:by_age,@test_asset))
    end

    it 'calculates if by age and mileage are equal' do
      @test_asset.update!(:purchased_new => false)
      @mileage_update_event.current_mileage = @test_asset.policy_analyzer.get_min_service_life_miles + 100
      @mileage_update_event.event_date = Date.new(test_calculator.send(:by_age,@test_asset),7,1)
      @mileage_update_event.save

      service_life = test_calculator.calculate(@test_asset)

      if_equal_age = service_life == test_calculator.send(:by_age,@test_asset)
      if_equal_mileage = service_life == test_calculator.send(:by_mileage,@test_asset)
      expect(if_equal_age && if_equal_mileage).to be true
    end
  end

  describe '#by_mileage' do
    it 'calculates' do
      @mileage_update_event.current_mileage = @test_asset.policy_analyzer.get_min_service_life_miles + 100
      @mileage_update_event.save
      expect(test_calculator.send(:by_mileage,@test_asset)).to eq(fiscal_year_year_on_date(Date.today))
    end

    it 'calculates if current mileage is max service life miles' do
      @mileage_update_event.current_mileage = @test_asset.policy_analyzer.get_min_service_life_miles
      @mileage_update_event.save
      expect(test_calculator.send(:by_mileage,@test_asset)).to eq(fiscal_year_year_on_date(Date.today))
    end

    it 'is by age if current mileage is less than max service life miles' do
      expect(test_calculator.send(:calculate,@test_asset)).to eq(test_calculator.send(:by_age,@test_asset))
    end
  end
end
