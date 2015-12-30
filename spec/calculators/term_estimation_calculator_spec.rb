require 'rails_helper'
include FiscalYear

RSpec.describe TermEstimationCalculator, :type => :calculator do

  before(:each) do
    # NB: validate_location_reference actually lives in TransamGeoLocatable
    #   but must be stubbed to catch invalid references to GisService
    #   which require non-sqlite-able columns (from spatial)
    allow_any_instance_of(Structure).to receive(:validate_location_reference).and_return(nil)
    @organization = create(:organization)
    @policy = create(:policy, :organization => @organization)
  end

  let(:test_calculator) { TermEstimationCalculator.new }

  describe '#calculate' do
    it 'vehicle under 3yo calculates' do
      test_asset = create(:bus, {:in_service_date => Date.today - 2.years, :organization => @organization, :asset_type => AssetType.first})
      create(:policy_asset_type_rule, :policy => @policy, :asset_type => test_asset.asset_type)
      create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)
      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.4167)
    end

    it 'vehicle over 3yo calculates' do
      test_asset = create(:bus, {:in_service_date => Date.today - 4.years, :organization => @organization, :asset_type => AssetType.first})
      create(:policy_asset_type_rule, :policy => @policy, :asset_type => test_asset.asset_type)
      create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)
      expect(test_calculator.calculate(test_asset).round(4)).to eq(3.0716)
    end

    it 'rail car under 2.5yo calculates' do
      test_asset = create(:light_rail_car, {:in_service_date => Date.today - 2.years, :organization => @organization, :asset_type => AssetType.find_by(:class_name => "RailCar")})
      create(:policy_asset_type_rule, :policy => @policy, :asset_type => test_asset.asset_type)
      create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)

      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.25)
    end

    it 'rail car over 2.5yo calculates' do
      test_asset = create(:light_rail_car, {:in_service_date => Date.today - 4.years, :organization => @organization, :asset_type => AssetType.find_by(:class_name => "RailCar")})
      create(:policy_asset_type_rule, :policy => @policy, :asset_type => test_asset.asset_type)
      create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
      mileage_update_event = create(:mileage_update_event, :asset => test_asset)

      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.1905)
    end

    it 'support facility under 18yo calculates' do
      test_asset = create(:administration_building, {:in_service_date => Date.today - 2.years, :organization => @organization, :asset_type => AssetType.find_by(:class_name => "SupportFacility")})
      create(:policy_asset_type_rule, :policy => @policy, :asset_type => test_asset.asset_type)
      create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => test_asset.asset_subtype)

      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.89)
    end

    it 'support facility over 18yo calculates' do
      test_asset = create(:administration_building, {:in_service_date => Date.today - 20.years, :organization => @organization})
      expect(test_calculator.calculate(test_asset).round(4)).to eq(3.2033)
    end

    it 'transit facility calculates' do
      test_asset = create(:bus_shelter, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.9917)
    end

    it 'fixed guideway calculates' do
      class FixedGuideway < Asset; end
      test_asset = create(:fixed_guideway, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.calculate(test_asset).round(4)).to eq(4.791)
    end

  end

  describe '#last_serviceable_year' do
    it 'vehicle calculates' do
      test_asset = create(:bus, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(fiscal_year_year_on_date(Date.today)+14)
    end

    it 'rail car calculates' do
      test_asset = create(:light_rail_car, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(fiscal_year_year_on_date(Date.today)+28)
    end

    it 'support facility calculates' do
      test_asset = create(:administration_building, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(fiscal_year_year_on_date(Date.today)+77)
    end

    it 'transit facility calculates' do
      test_asset = create(:bus_shelter, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(fiscal_year_year_on_date(Date.today)+27)
    end

    it 'fixed guideway calculates' do
      class FixedGuideway < Asset; end
      test_asset = create(:fixed_guideway, {:in_service_date => Date.today - 2.years, :organization => @organization})
      expect(test_calculator.last_servicable_year(test_asset)).to eq(fiscal_year_year_on_date(Date.today)+40)
    end
  end
end
