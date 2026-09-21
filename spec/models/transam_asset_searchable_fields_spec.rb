require 'rails_helper'

# TTPLAT-3072 P2 M2b. Tests TransamAsset#searchable_fields (transam_asset.rb:317-333 in the
# bundled transam_core gem), a core-engine method, but only transit's own model classes can
# exercise every code path (the acting_as loop vs. the superclass-inheritance path CapitalEquipment
# hits) -- transam_core has no test double reaching the second path. Placed under spec/models/
# rather than spec/models/concerns/ or transam_core to match how this repo's other model specs are
# laid out; not touching transam_core itself is also required by TTPLAT-3072 §0.
RSpec.describe "TransamAsset#searchable_fields", type: :model do

  before(:each) do
    @organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: @organization, parent: parent_policy)
  end

  # Legacy transam_transit/spec/models/concrete_asset_spec.rb:58-75 exercises this same method
  # (then on the old `Asset`/`RollingStock`/`Vehicle` hierarchy) for a `bus`, its closest analog to
  # today's RevenueVehicle. That example built its expectation partly from STRINGS
  # (`support_vehicle_searchables = [ 'license_plate', 'serial_number' ]`, line 64) while every
  # current survivor constant is SYMBOLS, so transposing those literals would fail on element type
  # before order ever mattered. Built fresh from the real constants instead. Per J4: match_array,
  # not eql -- order isn't semantically meaningful, and the current method assembles leaf-first
  # (RevenueVehicle -> ServiceVehicle -> TransitAsset -> TransamAsset) where the legacy one built
  # base-first.
  #
  # RevenueVehicle (depth 4: RevenueVehicle -> ServiceVehicle -> TransitAsset -> TransamAsset)
  # defines no SEARCHABLE_FIELDS of its own, so the actual method never reaches its own class's
  # constant lookup at all -- the entire result comes from the acting_as loop (transam_asset.rb
  # :327-331), which is the same code path Facility uses below, NOT the superclass branch (line
  # 323) that CapitalEquipment reaches instead. Confirmed by reading acting_as_model at each level
  # and by calling searchable_fields on a real, saved RevenueVehicle -- this is its actual return
  # value, not an inference:
  #   [:license_plate, :serial_number, :fta_type, :title_number, :object_key, :asset_tag,
  #    :external_id, :description, :manufacturer_model]
  # No legacy `:fta_bus_mode_type` anywhere in this list (or in any SEARCHABLE_FIELDS constant
  # transit or core defines) -- FtaBusModeType is deprecated in core.
  it 'assembles RevenueVehicle fields from ServiceVehicle, TransitAsset and TransamAsset' do
    revenue_vehicle = create(:revenue_vehicle, organization: @organization)

    expect(revenue_vehicle.searchable_fields).to match_array(
      ServiceVehicle::SEARCHABLE_FIELDS + TransitAsset::SEARCHABLE_FIELDS + TransamAsset::SEARCHABLE_FIELDS
    )
  end

  # Same legacy source and same departures as RevenueVehicle above (no equivalent standalone
  # "facility" subject existed in the legacy spec; the shape of the assertion is what's mirrored,
  # not a specific legacy example). Facility DOES define its own SEARCHABLE_FIELDS
  # (facility.rb:129-137), so unlike RevenueVehicle the method's first step (transam_asset.rb:320)
  # picks that constant up directly, then the acting_as loop (Facility -> TransitAsset ->
  # TransamAsset) appends the rest. Facility's superclass is TransamAssetRecord directly, so it
  # does not reach the superclass branch (line 323) either. Confirmed by calling searchable_fields
  # on a real, saved Facility:
  #   [:facility_name, :address1, :address2, :city, :state, :zip, :fta_type, :title_number,
  #    :object_key, :asset_tag, :external_id, :description, :manufacturer_model]
  it "assembles Facility's own fields plus TransitAsset's and TransamAsset's" do
    facility = create(:facility, organization: @organization)

    expect(facility.searchable_fields).to match_array(
      Facility::SEARCHABLE_FIELDS + TransitAsset::SEARCHABLE_FIELDS + TransamAsset::SEARCHABLE_FIELDS
    )
  end

  # Mirrors transam_core/spec/models/asset_spec.rb:186-192 (an untyped/abstract asset -- there,
  # `buslike_asset`; here, a bare TransamAsset with no associated typed subclass row).  That
  # example's own expectation (`asset_searchables = [:object_key, :asset_tag, :external_id,
  # :description, :manufacturer_model]`) already used symbols and already matched what
  # TransamAsset::SEARCHABLE_FIELDS (transam_asset.rb:124-130) holds today, so this genuinely
  # carries over unchanged in substance; only the eql -> match_array switch (J4) and the vehicle
  # for the assertion differ. A bare TransamAsset has no typed subclass to type itself as
  # (`TransamAsset.get_typed_asset` returns it unchanged), its superclass is TransamAssetRecord
  # directly (skips line 323), and it has no `acting_as_model` (TransamAsset is the target other
  # classes act as, not itself an actor) so the loop at 327-331 never runs. The result is exactly
  # its own constant, confirmed on a real instance:
  #   [:object_key, :asset_tag, :external_id, :description, :manufacturer_model]
  it 'returns only its own fields for a bare, untyped TransamAsset' do
    bare = TransamAsset.new

    expect(bare.searchable_fields).to match_array(TransamAsset::SEARCHABLE_FIELDS)
  end

  # No legacy counterpart tests this exact shape -- transam_core has no subclass whose own class
  # inherits (via plain Ruby subclassing, not acts_as) a SEARCHABLE_FIELDS constant from its
  # superclass, so this is CapitalEquipment-specific new coverage of a real quirk.
  #
  # CapitalEquipment is the only one of the four subjects that reaches the superclass branch at
  # transam_asset.rb:323-325, and it does so by a different mechanism than the brief's framing of
  # "the superclass branch" might suggest: CapitalEquipment defines no SEARCHABLE_FIELDS of its
  # own, so `typed_self.class::SEARCHABLE_FIELDS` at line 320 already resolves -- via ordinary
  # Ruby constant lookup up CapitalEquipment's OWN class hierarchy (CapitalEquipment < TransitAsset
  # directly, capital_equipment.rb:1) -- to TransitAsset::SEARCHABLE_FIELDS. The superclass branch
  # then appends `typed_self.class.superclass::SEARCHABLE_FIELDS`, which is the SAME
  # TransitAsset::SEARCHABLE_FIELDS constant, a second time. `CapitalEquipment.superclass` really
  # is TransitAsset (not TransamAssetRecord), so the `!= "TransamAssetRecord"` gate really is true
  # for CapitalEquipment and false for RevenueVehicle/Facility (both descend from
  # TransamAssetRecord directly) -- confirmed by inspecting `.superclass` on all four classes, not
  # just read from the source. The acting_as loop then still runs on top of that (CapitalEquipment
  # inherits TransitAsset's `acting_as_model` -- TransamAsset -- as a class-level attribute, despite
  # never calling `acts_as` itself), appending TransamAsset::SEARCHABLE_FIELDS once more.
  #
  # Net effect: :fta_type and :title_number each appear TWICE in the real, observed return value.
  # This looks like an unintended double-count (TransitAsset::SEARCHABLE_FIELDS effectively
  # doubled) rather than a deliberate design -- flagged in the P2 report as a candidate ticket, not
  # fixed here (TTPLAT-3072 §0: no application code changes) and not asserted away: the duplication
  # below is CapitalEquipment's actual behavior, confirmed by calling searchable_fields on a real,
  # saved CapitalEquipment:
  #   [:fta_type, :title_number, :fta_type, :title_number, :object_key, :asset_tag, :external_id,
  #    :description, :manufacturer_model]
  #
  # Also confirms the brief's second accepted departure: no bare `:serial_number` on
  # CapitalEquipment anywhere in this list -- capital_equipment.rb:21-33 carries multiple serial
  # numbers through core's polymorphic SerialNumber instead (`serial_number_strings`, not a
  # searchable field).
  it 'double-counts TransitAsset fields via both constant inheritance and the superclass branch' do
    capital_equipment = create(:capital_equipment, organization: @organization)

    expect(capital_equipment.searchable_fields).to match_array(
      TransitAsset::SEARCHABLE_FIELDS + TransitAsset::SEARCHABLE_FIELDS + TransamAsset::SEARCHABLE_FIELDS
    )
    expect(capital_equipment.searchable_fields).not_to include(:serial_number)
  end
end
