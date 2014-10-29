require 'rails_helper'

RSpec.describe TermEstimationCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  module TransamGeoLocatable; end

  class Structure < Asset; end

  before(:each) do
    @organization = create(:organization)
    @policy = create(:policy, :organization => @organization)
  end

  let(:test_calculator) { TermEstimationCalculator.new }

  describe '#calculate' do
    it 'vehicle under 3yo calculates' do
      test_asset = create(:bus, {:manufacture_year => Date.today - 2.years, :organization => @organization, :asset_type => create(:asset_type)})
      policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)
      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.4167)
    end

    it 'vehicle over 3yo calculates' do
      test_asset = create(:bus, {:manufacture_year => Date.today - 4.years, :organization => @organization, :asset_type => create(:asset_type)})
      policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)
      expect(test_calculator.calculate(test_asset).round(4)).to eq(3.0716)
    end

    it 'rail car under 2.5yo calculates' do
      test_asset = create(:light_rail_car, {:manufacture_year => Date.today - 2.years, :organization => @organization, :asset_type => create(:asset_type, :class_name => "RailCar")})
      policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)

      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.25)
    end

    it 'rail car over 2.5yo calculates' do
      test_asset = create(:light_rail_car, {:manufacture_year => Date.today - 4.years, :organization => @organization, :asset_type => create(:asset_type, :class_name => "RailCar")})
      policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)

      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.1905)
    end

    it 'support facility under 18yo calculates' do
      test_asset = create(:administration_building, {:manufacture_year => Date.today - 2.years, :organization => @organization, :asset_type => create(:asset_type, :class_name => "SupportFacility")})
      policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)

      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.89)
    end

    it 'support facility over 18yo calculates' do
      test_asset = create(:administration_building, {:manufacture_year => Date.today - 20.years, :organization => @organization})
      expect(test_calculator.calculate(test_asset).round(4)).to eq(3.2033)
    end

    it 'transit facility calculates' do
      test_asset = create(:bus_shelter, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.9917)
    end

    it 'fixed guideway calculates' do
      class FixedGuideway < Asset; end
      test_asset = create(:fixed_guideway, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.791)
    end

  end

  describe '#last_serviceable_year' do
    it 'vehicle calculates' do
      test_asset = create(:bus, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(2028)
    end

    it 'rail car calculates' do
      test_asset = create(:light_rail_car, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(2042)
    end

    it 'support facility calculates' do
      test_asset = create(:administration_building, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(2091)
    end

    it 'transit facility calculates' do
      test_asset = create(:bus_shelter, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(2041)
    end

    it 'fixed guideway calculates' do
      class FixedGuideway < Asset; end
      test_asset = create(:fixed_guideway, {:manufacture_year => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(2054)
    end
  end
end
