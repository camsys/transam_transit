require 'rails_helper'

RSpec.describe CapitalEquipment, type: :model do

  # Handle PolicyAware requirements (TTPLAT-3072 P1 §2.3 pattern -- see revenue_vehicle_spec.rb)
  before(:each) do
    @organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: @organization, parent: parent_policy)
    @capital_equipment = create(:capital_equipment, organization: @organization)
  end

  # Mirrors transam_core/spec/models/equipment_spec.rb:9-12 (quantity presence). Carries over
  # unchanged -- CapitalEquipment validates :quantity, presence: true (capital_equipment.rb:10)
  # exactly as legacy Equipment did.
  describe 'quantity' do
    it 'must exist' do
      @capital_equipment.quantity = nil
      expect(@capital_equipment.valid?).to be false
    end

    # Mirrors transam_core/spec/models/equipment_spec.rb:13-16 (quantity numericality). Carries
    # over unchanged.
    it 'must be a number' do
      @capital_equipment.quantity = 'abc'
      expect(@capital_equipment.valid?).to be false
    end

    # Mirrors transam_core/spec/models/equipment_spec.rb:17-20 (quantity > 0). Carries over
    # unchanged -- capital_equipment.rb:12 validates numericality greater_than: 0.
    it 'must be greater than 0' do
      @capital_equipment.quantity = -2
      expect(@capital_equipment.valid?).to be false
    end
  end

  # Mirrors transam_core/spec/models/equipment_spec.rb:22-25, with a rename: legacy Equipment
  # validated `quantity_units` (plural). CapitalEquipment's real attribute is `quantity_unit`
  # (singular) -- see capital_equipment.rb:11, `validates :quantity_unit, presence: true`.
  # CapitalEquipment does not respond to `quantity_units` at all.
  it 'must have a quantity unit' do
    @capital_equipment.quantity_unit = nil
    expect(@capital_equipment.valid?).to be false
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen. CapitalEquipment
  # validates four attributes legacy Equipment did not (capital_equipment.rb:9-15).
  describe 'manufacture_year' do
    it 'must exist' do
      @capital_equipment.manufacture_year = nil
      expect(@capital_equipment.valid?).to be false
    end
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen.
  describe 'description' do
    it 'must exist' do
      @capital_equipment.description = nil
      expect(@capital_equipment.valid?).to be false
    end
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen.
  describe 'other_manufacturer' do
    it 'must exist' do
      @capital_equipment.other_manufacturer = nil
      expect(@capital_equipment.valid?).to be false
    end
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen.
  describe 'other_manufacturer_model' do
    it 'must exist' do
      @capital_equipment.other_manufacturer_model = nil
      expect(@capital_equipment.valid?).to be false
    end
  end

  # Legacy transam_core/spec/models/equipment_spec.rb:28-33 asserted
  # `Equipment.allowable_params == [:quantity, :quantity_units]`, a class method Equipment defined
  # itself. CapitalEquipment defines no `allowable_params` class or instance method, and
  # `CapitalEquipment::FORM_PARAMS` (capital_equipment.rb:17-19) is just `[:serial_number_strings]`
  # -- an unrelated, much shorter list that is not what `allowable_params` returns either.
  #
  # The real `allowable_params` is an INSTANCE method inherited from TransamAssetRecord
  # (transam_asset_record.rb:93-113, in the bundled gem). It combines, in order:
  #   1. `self.class::FORM_PARAMS` (CapitalEquipment::FORM_PARAMS -- [:serial_number_strings])
  #   2. the superclass's FORM_PARAMS, since CapitalEquipment.superclass (TransitAsset) is not
  #      "TransamAssetRecord" (TransitAsset::FORM_PARAMS, transit_asset.rb:56-70)
  #   3. each `acting_as_model` in the chain's FORM_PARAMS (TransamAsset::FORM_PARAMS,
  #      transam_asset.rb:92-116, reached via TransitAsset's `acts_as :transam_asset`)
  #   4. a trailing `{dependents_attributes: [...]}` entry -- always appended for a non-child
  #      asset class (CapitalEquipment.child_asset_class? is false; checked db/data_migrations in
  #      both repos and confirmed the only class with `self.child_asset_class = true` is
  #      TransitComponent, in app/models/transit_component.rb -- not CapitalEquipment)
  #   5. any db/data_migrations-injected SystemConfigExtension mixin active for class_name
  #      'TransamAsset' whose `ClassMethods` defines `allowable_params`. Two are active
  #      (PolicyAware, ReplaceableAsset -- see
  #      db/data_migrations/20190215194637_add_transit_engine_name_system_config_extensions.rb and
  #      transam_core's 20190123131354_add_policy_replacement_core_mixins.rb), but only
  #      ReplaceableAsset::ClassMethods defines `allowable_params`
  #      (transam_core/app/models/concerns/replaceable_asset.rb:62-67); PolicyAware's does not.
  #
  # Confirmed by actually calling `allowable_params` on a real CapitalEquipment: the array
  # asserted below is its observed return value, not an inference from reading the source alone.
  #
  # One more wrinkle, also confirmed by observation rather than assumed: the `dependents_attributes`
  # entry's content is NOT determined by CapitalEquipment at all -- `allowable_params`
  # (transam_asset_record.rb:97-100) walks *every* `TransamAssetRecord.subclasses` looking for
  # `child_asset_class? == true` (currently only TransitComponent, transit_component.rb:2), and
  # Ruby's constant-autoloading means that list is only as complete as whatever classes have
  # already been loaded elsewhere in the process. Running this example in isolation, before
  # anything else references `TransitComponent`, produces `dependents_attributes: []`; running the
  # full suite, where `transit_component_spec.rb` loads it first, produces it fully populated.
  # That is a genuine flakiness in the method (its result depends on unrelated load order, not
  # just on `self`), worth a candidate ticket -- but not fixed here (TTPLAT-3072 §0). Referencing
  # `TransitComponent` up front makes this example itself deterministic either way.
  it '#allowable_params' do
    TransitComponent # force autoload so :dependents_attributes matches full-suite load order

    expect(@capital_equipment.allowable_params).to eq(
      CapitalEquipment::FORM_PARAMS +
      TransitAsset::FORM_PARAMS +
      TransamAsset::FORM_PARAMS +
      [{dependents_attributes: TransitComponent.new.typed_asset_params}] +
      ReplaceableAsset::ClassMethods.allowable_params
    )
  end

  # Mirrors transam_core/spec/models/equipment_spec.rb:35-37 (`.cost == purchase_cost`). Legacy
  # `Equipment#cost` (equipment.rb:96-98 in the bundled gem) was its own explicit override
  # ("The cost of a equipment asset is the purchase cost" / `purchase_cost`), overriding the
  # generic `Asset#cost` (asset.rb:693-696), which types the asset and delegates back to it.
  # CapitalEquipment defines no `cost` of its own, and neither does TransitAsset -- the method
  # that actually runs is `TransamAsset#cost` (transam_asset.rb:435-437 in the bundled gem,
  # reached the same way `allowable_params` is -- through TransitAsset's `acts_as :transam_asset`),
  # which is a plain `purchase_cost` passthrough, same shape as legacy's override. Carries over
  # with the same outcome, only via a different, uncustomized method.
  it '.cost' do
    expect(@capital_equipment.cost).to eq(@capital_equipment.purchase_cost)
  end

  # Legacy transam_core/spec/models/equipment_spec.rb:39-44 (`.set_defaults` giving quantity == 1,
  # quantity_units == Uom::UNIT). Checked both capital_equipment.rb and transit_asset.rb directly,
  # and grepped `set_defaults` across db/data_migrations in both transam_transit and the bundled
  # transam_core gem (per TTPLAT-3072 §0) -- neither CapitalEquipment nor TransitAsset defines a
  # `set_defaults` method, callback, or injected mixin of that name; `respond_to?(:set_defaults,
  # true)` is false and no `after_initialize` is registered for it on either class. This legacy
  # behavior genuinely has no counterpart on CapitalEquipment: nothing seeds quantity/quantity_unit
  # defaults on a new, unsaved instance. Not asserted here, and nothing is invented in its place --
  # this is reported as a finding, not a defect, since no other code path appears to depend on
  # CapitalEquipment#new having these defaults pre-filled.
end
