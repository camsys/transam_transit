# require 'rails_helper'
#
# RSpec.describe TermEstimationCalculator, :type => :calculator do
#
#   class TestOrg < Organization
#     def get_policy
#       return Policy.where("`organization_id` = ?",self.id).order('created_at').last
#     end
#   end
#
#   module TransamGeoLocatable; end
#
#   class Structure < Asset; end
#
#   before(:each) do
#     @organization = create(:organization)
#     @policy = create(:policy, :organization => @organization)
#   end
#
#   let(:test_calculator) { TermEstimationCalculator.new }
#
#   describe '#calculate' do
#     it 'vehicle under 3yo calculates' do
#       test_asset = create(:bus, {:manufacture_year => Date.today - 2.years, :organization => @organization, :asset_type => create(:asset_type)})
#       policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
#       mileage_update_event = create(:mileage_update_event, :asset => test_asset)
#       expect(test_calculator.calculate(test_asset).round(4)).to eq(4.4167)
#     end
#
#     it 'vehicle over 3yo calculates' do
#       test_asset = create(:bus, {:manufacture_year => Date.today - 4.years, :organization => @organization, :asset_type => create(:asset_type)})
#       policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
#       mileage_update_event = create(:mileage_update_event, :asset => test_asset)
#       expect(test_calculator.calculate(test_asset).round(4)).to eq(3.0716)
#     end
#
#     # it 'vehicle last serviceable year returns condition threshold' do
#     #   test_asset = create(:bus, :organization => @organization)
#     #   last_serviceable_year = test_calculator.last_servicable_year(test_asset)
#     #   years_from_now = [last_serviceable_year - Date.today.year, 0].max
#     #   test_asset.manufacture_year = Date.today - years_from_now
#     #   test_asset.save
#     #
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(test_asset.policy.condition_threshold)
#     # end
#
#     it 'rail car under 2.5yo calculates' do
#       test_asset = create(:light_rail_car, {:manufacture_year => Date.today - 2.years, :organization => @organization, :asset_type => create(:asset_type, :class_name => "RailCar")})
#       policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
#       mileage_update_event = create(:mileage_update_event, :asset => test_asset)
#
#       expect(test_calculator.calculate(test_asset).round(4)).to eq(4.25)
#     end
#
#     it 'rail car over 2.5yo calculates' do
#       test_asset = create(:light_rail_car, {:manufacture_year => Date.today - 4.years, :organization => @organization, :asset_type => create(:asset_type, :class_name => "RailCar")})
#       policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
#       mileage_update_event = create(:mileage_update_event, :asset => test_asset)
#
#       expect(test_calculator.calculate(test_asset).round(4)).to eq(4.1905)
#     end
#
#     # it 'rail car last serviceable year returns condition threshold' do
#     #   test_asset = create(:light_rail_car, :organization => @organization)
#     #   last_serviceable_year = test_calculator.last_serviceable_year(test_asset)
#     #   years_from_now = [last_serviceable_year - Date.today, 0].max
#     #   test_asset.manufacture_year = Date.today - years_from_now
#     #   test_asset.save
#     #
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(test_asset.policy.condition_threshold)
#     # end
#
#     it 'support facility under 18yo calculates' do
#       #class GisService::GeometryFactory; end
#
#       test_asset = create(:administration_building, {:manufacture_year => Date.today - 2.years, :organization => @organization, :asset_type => create(:asset_type, :class_name => "SupportFacility")})
#       policy_item = create(:policy_item, :policy => @policy, :asset_subtype => test_asset.asset_subtype)
#       #mileage_update_event = create(:mileage_update_event, :asset => test_asset)
#
#
#       expect(test_calculator.calculate(test_asset).round(4)).to eq(0)
#     end
#     #
#     # it 'support facility over 18yo calculates' do
#     #   test_asset = create(:administration_building, {:manufacture_year => Date.today - 4.years, :organization => @organization})
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(0)
#     # end
#     #
#     # it 'support facility last serviceable year returns condition threshold' do
#     #   test_asset = create(:administration_building, :organization => @organization)
#     #   last_serviceable_year = test_calculator.last_serviceable_year(test_asset)
#     #   years_from_now = [last_serviceable_year - Date.today, 0].max
#     #   test_asset.manufacture_year = Date.today - years_from_now
#     #   test_asset.save
#     #
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(test_asset.policy.condition_threshold)
#     # end
#     #
#     # it 'transit facility calculates' do
#     #   test_asset = create(:bus_shelter, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(0)
#     # end
#     #
#     # it 'transit facility last serviceable year returns condition threshold' do
#     #   test_asset = create(:bus_shelter, :organization => @organization)
#     #   last_serviceable_year = test_calculator.last_serviceable_year(test_asset)
#     #   years_from_now = [last_serviceable_year - Date.today, 0].max
#     #   test_asset.manufacture_year = Date.today - years_from_now
#     #   test_asset.save
#     #
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(test_asset.policy.condition_threshold)
#     # end
#     #
#     # it 'fixed guideway calculates' do
#     #   test_asset = create(:fixed_guideway, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(0)
#     # end
#     #
#     # it 'fixed guideway last serviceable year returns condition threshold' do
#     #   test_asset = create(:fixed_guideway, :organization => @organization)
#     #   last_serviceable_year = test_calculator.last_serviceable_year(test_asset)
#     #   years_from_now = [last_serviceable_year - Date.today, 0].max
#     #   test_asset.manufacture_year = Date.today - years_from_now
#     #   test_asset.save
#     #
#     #   expect(test_calculator.calculate(test_asset).round(4)).to eq(test_asset.policy.condition_threshold)
#     # end
#
#   end
#
#   # describe '#last_serviceable_year' do
#   #   it 'vehicle calculates' do
#   #     test_asset = create(:bus, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#   #     expect(test_calculator.last_serviceable_year(test_asset)).to eq(num)
#   #   end
#   #
#   #   it 'rail car calculates' do
#   #     test_asset = create(:light_rail_car, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#   #     expect(test_calculator.last_serviceable_year(test_asset)).to eq(num)
#   #   end
#   #
#   #   it 'support facility calculates' do
#   #     test_asset = create(:administration_building, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#   #     expect(test_calculator.last_serviceable_year(test_asset)).to eq(num)
#   #   end
#   #
#   #   it 'transit facility calculates' do
#   #     test_asset = create(:bus_shelter, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#   #     expect(test_calculator.last_serviceable_year(test_asset)).to eq(num)
#   #   end
#   #
#   #   it 'fixed guideway calculates' do
#   #     test_asset = create(:fixed_guideway, {:manufacture_year => Date.today - 2.years, :organization => @organization})
#   #     expect(test_calculator.last_serviceable_year(test_asset)).to eq(num)
#   #   end
#   # end
# end
