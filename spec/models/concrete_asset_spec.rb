require 'rails_helper'

RSpec.describe Asset, :type => :model do

  let(:bus) { create(:bus) }
  let(:buslike_asset) { create(:buslike_asset)}
  let(:lrc) { build_stubbed(:light_rail_car) }
  let(:loco) { build_stubbed(:commuter_locomotive_diesel) }
  let(:shelter) { build_stubbed(:bus_shelter) }
  let(:adminb) { build_stubbed(:administration_building) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  describe ".new_asset" do # pending
    it "returns a typed asset" do
      a = Asset.new_asset(bus.asset_subtype)
      rail = Asset.new_asset(lrc.asset_subtype)
      new_loco = Asset.new_asset(loco.asset_subtype)

      expect(a.class).to eq(Vehicle)
      expect(rail.class).to eq(RailCar)
      expect(new_loco.class).to eq(Locomotive)
    end
  end

  describe ".get_typed_asset" do
    it "types an untyped asset" do
      expect(Asset.get_typed_asset(buslike_asset).class).to eq(Vehicle)
    end

    it "types an already typed asset" do
      expect(Asset.get_typed_asset(bus).class).to eq(Vehicle)
    end

    it "returns nil when handed nothing" do
      expect(Asset.get_typed_asset(nil)).to be_nil
    end
  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  describe "#is_typed?" do
    it 'returns true for strongly typed assets' do
      expect(bus.is_typed?).to be(true)
    end

    it 'returns false for Asset' do
      expect(buslike_asset.is_typed?).to be(false)
    end
  end

  describe "#searchable_fields" do
    it 'inherits down the tree' do
      asset_searchables = [
        :object_key,
        :asset_tag,
        :external_id,

        :asset_type,
        :asset_subtype,

        :manufacturer,
        :manufacturer_model,
        :manufacture_year
      ]
      rolling_stock_searchables = [ 'purchase_date', 'title_number', 'description' ]
      fta_vehicle_searchables = []
      support_vehicle_searchables = [ 'license_plate', 'serial_number']
      vehicle_searchables = ['license_plate', 'serial_number']
      structure_searchables = ['description', 'address1', 'address2', 'city', 'state', 'zip']

      expect(buslike_asset.searchable_fields).to eql(asset_searchables)
      expect(bus.searchable_fields).to eql(asset_searchables + rolling_stock_searchables + fta_vehicle_searchables + vehicle_searchables)
      expect(lrc.searchable_fields).to eql(asset_searchables + rolling_stock_searchables + fta_vehicle_searchables)
      expect(loco.searchable_fields).to eql(asset_searchables + rolling_stock_searchables + fta_vehicle_searchables)
      expect(shelter.searchable_fields).to eql(asset_searchables + structure_searchables)
      expect(adminb.searchable_fields).to eql(asset_searchables + structure_searchables)
    end
  end

  describe "#cost" do
    describe 'for a concrete asset' do
      it 'returns the correct cost' do
        expect(bus.cost).to eql(250000)
      end
    end

    describe 'for an abstract asset' do
      it 'returns the correct cost' do
        expect(buslike_asset.cost).to eql(250000)
      end
    end
  end

  describe "#name" do
    it 'returns the correct default name for an asset' do
      buslike_asset.update_attributes(asset_tag: "TEST") # Need a defined asset_tag for this test
      expect(buslike_asset.name).to eql("Bus Std 40 FT - TEST")
    end
  end

  describe "#type_of?" do
    it 'returns true when testing own class' do
      expect(bus.type_of?(:vehicle)).to be true
    end

    it 'returns true when testing up the tree' do
      expect(bus.type_of?(:asset)).to be true
    end

    it 'returns false when testing across branches' do
      expect(bus.type_of?(:geolocatable_asset)).to be false
    end

    it 'should return true/false when passed a symbol, string or classname' do
      expect(bus.type_of?(:rolling_stock)).to be true
      expect(bus.type_of?("rolling_stock")).to be true
      expect(bus.type_of?(RollingStock)).to be true
    end

    it 'should return false for anything other than Symbol, String, or Class' do
      expect(bus.type_of?(buslike_asset)).to be false
      expect(bus.type_of?(2)).to be false
      expect(bus.type_of?(1..2)).to be false
      expect(bus.type_of?(ArgumentError)).to be false
    end
  end

  describe "#record_disposition" do
    it 'works for a concrete type' do
      bus.disposition_updates.build(attributes_for(:disposition_update_event))
      bus.record_disposition

      expect(bus.disposition_date).to eq(Date.today)
      expect(bus.disposition_type_id).to eq(2)
    end

    it 'works for an abstract Asset' do
      buslike_asset.disposition_updates.create(attributes_for(:disposition_update_event))
      buslike_asset.record_disposition
      buslike_asset.reload

      expect(buslike_asset.disposition_date).to eq(Date.today)
      expect(buslike_asset.disposition_type_id).to eq(2)
    end
  end

  describe "#update_service_status" do
    it 'works for a concrete type' do
      bus.service_status_updates.create(attributes_for(:service_status_update_event))
      bus.update_service_status
      buslike_asset.reload

      expect(bus.service_status_date).to eq(Date.today)
      expect(bus.service_status_type_id).to eq(2)
    end

    it 'works for an abstract type' do
      buslike_asset.service_status_updates.create(attributes_for(:service_status_update_event))
      buslike_asset.update_service_status
      buslike_asset.reload

      expect(buslike_asset.service_status_date).to eq(Date.today)
      expect(buslike_asset.service_status_type_id).to eq(2)
    end
  end

  describe "#update_condition" do
    it 'works for a concrete type' do
      bus.condition_updates.build(attributes_for(:condition_update_event))
      bus.update_condition

      expect(bus.reported_condition_rating).to eq(3)
    end

    it 'works for an abstract type' do
      buslike_asset.condition_updates.build(attributes_for(:condition_update_event))
      buslike_asset.update_condition
      buslike_asset.reload

      expect(buslike_asset.reported_condition_rating).to eq(3)
    end
  end

  describe '#copy' do
    describe "with a cleanse" do
      it 'copies class-specific fields for a concrete type' do
        copied_bus = bus.copy

        %w(class organization_id asset_type_id asset_subtype_id manufacturer_id manufacturer_model manufacture_year
          purchase_date expected_useful_miles fuel_type).each do |attribute_name|
          expect(copied_bus.send(attribute_name)).to eq(bus.send(attribute_name)),
          "#{attribute_name} expected: #{bus.send(attribute_name)}\n         got: #{copied_bus.send(attribute_name)}"
        end
      end

       it 'clears out cleansable_fields' do
        bus.license_plate = "ABC-123" # test a concrete class attribute
        copied_bus = bus.copy

        %w(object_key asset_tag policy_replacement_year estimated_replacement_year estimated_replacement_cost
          scheduled_replacement_year scheduled_rehabilitation_year scheduled_disposition_year replacement_reason_type_id
          in_backlog reported_condition_type_id reported_condition_rating reported_condition_date reported_mileage
          estimated_condition_type_id estimated_condition_rating service_status_type_id
          disposition_type_id disposition_date license_plate serial_number).each do |attribute_name|
          expect(copied_bus.send(attribute_name)).to be_blank,
          "expected '#{attribute_name}' to be blank, got #{copied_bus.send(attribute_name)}"
        end
      end
    end

    describe 'without a cleanse' do
      it 'does not clear out cleansable_fields' do
        bus.license_plate = "ABC-123" # test a concrete class attribute
        copied_bus = bus.copy(false)
        copied_bus.save

        %w(object_key asset_tag license_plate serial_number).each do |attribute_name|
          expect(copied_bus.send(attribute_name)).not_to be_blank,
          "expected '#{attribute_name}.blank?' to be false, got #{copied_bus.send(attribute_name).blank?}"
        end
      end

      it 'does not keep attached objects when passed a False' do
        bus.comments.build(:comment => "Test Comment")
        copied_bus = bus.copy(false)

        expect(copied_bus.comments.length).to eq(0)
      end
    end
  end


end
