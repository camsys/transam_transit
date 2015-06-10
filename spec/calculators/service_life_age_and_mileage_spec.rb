require 'rails_helper'

RSpec.describe ServiceLifeAgeAndMileage, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:bus, {:organization => @organization, :asset_type => create(:asset_type), :asset_subtype => create(:asset_subtype)})
    @policy = create(:policy, :organization => @organization)
    @policy_item = create(:policy_item, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)

    @mileage_update_event = create(:mileage_update_event, :asset => @test_asset)
  end

  let(:test_calculator) { ServiceLifeAgeAndMileage.new }

  describe '#calculate' do
    it 'calculates if by mileage is min' do
      @mileage_update_event.current_mileage = @test_asset.policy_rule.max_service_life_miles + 100
      @mileage_update_event.save
      expect(test_calculator.calculate(@test_asset)).to eq(test_calculator.send(:by_mileage,@test_asset))
    end

    it 'calculates if by age is min' do
      # set properties of mileage update event so year returned
      @mileage_update_event.current_mileage = @test_asset.policy_rule.max_service_life_miles + 100
      @mileage_update_event.event_date = '2999-01-01' # set it impossibly late in the future
      @mileage_update_event.save

      expect(test_calculator.calculate(@test_asset)).to eq(test_calculator.send(:by_age,@test_asset))
    end

    it 'calculates if by age and mileage are equal' do
      @test_asset.update!(:purchased_new => false)
      @mileage_update_event.current_mileage = @test_asset.policy_rule.max_service_life_miles + 100
      @mileage_update_event.event_date = test_calculator.send(:by_age,@test_asset)
      @mileage_update_event.save

      service_life = test_calculator.calculate(@test_asset)

      if_equal_age = service_life == test_calculator.send(:by_age,@test_asset)
      if_equal_mileage = service_life == test_calculator.send(:by_mileage,@test_asset)
      expect(if_equal_age && if_equal_mileage).to be true
    end
  end

  describe '#by_mileage' do
    it 'calculates' do
      @mileage_update_event.current_mileage = @test_asset.policy_rule.max_service_life_miles + 100
      @mileage_update_event.save
      expect(test_calculator.send(:by_mileage,@test_asset)).to eq(2014)
    end

    it 'calculates if current mileage is max service life miles' do
      @mileage_update_event.current_mileage = @test_asset.policy_rule.max_service_life_miles
      @mileage_update_event.save
      expect(test_calculator.send(:by_mileage,@test_asset)).to eq(2014)
    end

    it 'is by age if current mileage is less than max service life miles' do
      expect(test_calculator.send(:by_mileage,@test_asset)).to eq(test_calculator.send(:by_age,@test_asset))
    end
  end
end
