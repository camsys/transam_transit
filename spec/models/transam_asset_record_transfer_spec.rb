require 'rails_helper'

# TTPLAT-3072 P4 §2 (M3): TransamAssetRecord#transfer (transam_core bundled gem,
# transam_asset_record.rb:56-91). Reachable from production code via ServiceVehicle's,
# RevenueVehicle's and Facility's own `transfer` overrides (each calls `super`), but was at
# zero coverage before this pass -- nothing anywhere in transit's suite called `.transfer`.
# ServiceVehicle is used here because it needs the fewest extra fixtures of the three
# survivors to reach a saveable, disposed state.
RSpec.describe TransamAssetRecord, "#transfer" do
  # No legacy counterpart - added from the TTPLAT-3072 coverage screen.
  #
  # Provenance checked, not assumed: the M-list pairs M3 with the legacy `#copy` examples (core
  # asset_spec.rb:215-256, transit concrete_asset_spec.rb:184-232). Read both directly rather than
  # trusting the pairing (per P2's precedent, which found the same kind of spurious pairing for
  # M4): both sets of examples call `.copy`/`.copy(false)` on `buslike_asset`/`bus`, which are
  # instances of the *legacy* `Asset` model built via transit's own `:bus`/`:buslike_asset`
  # factories (spec/factories/concrete_assets.rb) -- `Vehicle < PassengerVehicle < FtaVehicle <
  # RollingStock < Asset`, a hierarchy TTPLAT-3072 P3 already confirmed is fully disjoint from
  # `TransamAssetRecord` (they share only `ActiveRecord::Base`). `Asset#copy`/`Asset#cleanse`
  # (bundled gem asset.rb:1120/1140) are textually near-identical but INDEPENDENTLY DEFINED
  # methods on that disjoint class -- a different method object from `TransamAssetRecord#copy`/
  # `#cleanse` (transam_asset_record.rb:43/50) that `transfer`'s own
  # `TransamAsset.get_typed_asset(self).copy false` call (line 59) actually invokes. Coverage of
  # `Asset#copy` cannot and does not put a single line of credit on `TransamAssetRecord#copy`, and
  # vice versa. **The pairing is spurious: there is no genuine legacy counterpart for M3.**

  # Why the two stubs below are here (corrected 2026-09-17 -- an earlier version of this comment
  # said `grant_purchases` "exists NOWHERE in either repo", which was wrong and was the product of
  # a search scoped to two repos). `TransitAsset#dup` (transit_asset.rb:108-112) reads and writes
  # `grant_purchases`, which is a real association -- injected into TransamAsset at runtime by
  # `TransamValuable` (transam_accounting/lib/transam_accounting/transam_valuable.rb:44), which
  # transam_accounting registers as a SystemConfigExtension
  # (db/data_migrations/20180605192939_add_accounting_system_config_extensions.rb:9, db/seeds.rb:78).
  #
  # Every client app loads transam_accounting, so this works in production. Transit's dummy app
  # loads core, transit and reporting only, so the association is absent *here* -- a harness
  # limitation, the same shape as core's dummy being unable to build a typed asset. Every
  # survivor's `#dup` reaches `transit_asset.dup`, and `transfer` calls
  # `TransamAsset.get_typed_asset(self).copy(false)` on its first line, so without these stubs
  # `transfer` raises NoMethodError in this harness before any of its own logic runs.
  #
  # The stubs stand in for an engine this dummy does not load. They touch no application code and
  # weaken no assertion about `transfer` itself. Separately, that transit calls an
  # accounting-injected association without a `respond_to?` gate is a real cross-engine coupling
  # defect -- same class as NEW-13, drafted as NEW-17 -- not fixed here.
  before(:each) do
    allow_any_instance_of(TransitAsset).to receive(:grant_purchases).and_return(nil)
    allow_any_instance_of(TransitAsset).to receive(:grant_purchases=)
  end

  let(:source_org) { create(:organization) }
  let(:target_org) { create(:organization) }

  before(:each) do
    # PolicyAware#check_policy_rule runs in an after_save on both the source and (crucially) the
    # transferred asset's new organization -- both need a policy chain built from P1's
    # :parent_policy factory or the save at the end of #transfer raises on a nil policy.
    parent_policy = create(:parent_policy)
    create(:policy, organization: source_org, parent: parent_policy)
    target_parent_policy = create(:parent_policy)
    create(:policy, organization: target_org, parent: target_parent_policy)
  end

  let(:source) { create(:service_vehicle, organization: source_org,
                         external_id: 'EXT-1',
                         pcnt_capital_responsibility: 50,
                         title_ownership_organization_id: source_org.id,
                         other_title_ownership_organization: 'Some Other Org',
                         operator_id: source_org.id,
                         other_operator: 'Some Other Operator') }

  # `purchase_cost = self.disposition_updates.last.sales_proceeds` (transam_asset_record.rb:67) is
  # unguarded -- an asset with no disposition update raises NoMethodError on nil, so the source
  # must be disposed first. Built the same way concrete_asset_spec.rb builds disposition events
  # (`<assoc>.disposition_updates.create(attributes_for(...))`, not
  # `create(:disposition_update_event, asset: ...)`): DispositionUpdateEvent#set_defaults
  # (transit's override) reads `self.send(...).disposition_updates` from `after_initialize`, and
  # FactoryBot's `create` strategy always calls the model's bare `.new` and assigns attributes
  # afterwards -- so the polymorphic `transam_asset` association is still nil when that callback
  # fires unless the record is built through the association itself, which sets the foreign key
  # before `after_initialize` runs.
  def dispose!(asset, sales_proceeds:)
    event = asset.disposition_updates.create(
      attributes_for(:disposition_update_event).merge(sales_proceeds: sales_proceeds, mileage_at_disposition: 1000)
    )
    raise "fixture setup failed: #{event.errors.full_messages}" unless event.persisted?

    # Second confirmed defect, adjacent to this one (see the P4 report): the after_save callback
    # this create fires (DispositionUpdateEvent#update_asset -> AssetDispositionUpdateJob) is
    # supposed to set disposition_date on the asset automatically, mirroring real disposal. It
    # doesn't: AssetDispositionUpdateJob#run re-types the asset via `get_typed_asset` before
    # calling `execute_job`, so `execute_job`'s `asset.update_columns(disposition_date: ...)` runs
    # against the *typed* asset (e.g. ServiceVehicle) rather than the base TransamAsset row, and
    # `update_columns` requires the column to exist on the model's own table -- it raises
    # ActiveModel::MissingAttributeError, which Job#perform's `rescue Exception` swallows and only
    # logs. Confirmed directly: calling `AssetDispositionUpdateJob.new(object_key).run` (bypassing
    # the rescue) raises exactly that error. Reaching the real lifecycle state (an actually-disposed
    # asset) therefore means setting the column directly, the same state the job is silently
    # failing to reach on its own -- not inventing a new one.
    asset.transam_asset.update_columns(disposition_date: Date.yesterday)
    asset.reload
  end

  describe "with serial numbers, condition updates and service status updates present" do
    before(:each) do
      dispose!(source, sales_proceeds: 25_000)
      source.condition_updates.create(attributes_for(:condition_update_event))
      source.service_status_updates.create(attributes_for(:service_status_update_event))
      SerialNumber.create(identifiable_type: 'TransamAsset', identifiable_id: source.transam_asset.id, identification: 'SER-123')
      source.reload
    end

    it "resets transfer-specific attributes, reassigns organization, and duplicates serial numbers, the last condition update and the last service-status update" do
      # and_call_original coverage proof (TTPLAT-3072 §5, mechanism 1): proves transit's suite
      # actually reaches transam_core's TransamAssetRecord#transfer and TransamAsset.get_typed_asset
      # (both defined only in the bundled gem), not just ServiceVehicle's own override.
      expect_any_instance_of(TransamAssetRecord).to receive(:transfer).and_call_original
      expect(TransamAsset).to receive(:get_typed_asset).at_least(:once).and_call_original

      original_condition_rating = source.condition_updates.last.assessed_rating
      original_service_status_type_id = source.service_status_updates.last.service_status_type_id
      original_object_key = source.object_key

      result = source.transfer(target_org.id)

      expect(result).to be_persisted
      expect(result).to be_a(ServiceVehicle)

      # Nilled fields (transam_asset_record.rb:60-72)
      expect(result.external_id).to be_nil
      expect(result.disposition_date).to be_nil
      expect(result.in_service_date).to be_nil
      expect(result.pcnt_capital_responsibility).to be_nil
      expect(result.title_ownership_organization_id).to be_nil
      expect(result.other_title_ownership_organization).to be_nil
      expect(result.operator_id).to be_nil
      expect(result.other_operator).to be_nil

      # Derived fields
      expect(result.purchase_date).to eq(source.disposition_date)
      expect(result.purchased_new).to eq(false)
      expect(result.purchase_cost).to eq(25_000) # source.disposition_updates.last.sales_proceeds

      # Reassignment + regenerated identity
      expect(result.organization_id).to eq(target_org.id)
      expect(result.object_key).not_to eq(original_object_key)
      expect(result.asset_tag).to eq(result.object_key)

      # Guarded copies, present branch
      expect(result.serial_numbers.count).to eq(1)
      expect(result.condition_updates.count).to eq(1)
      expect(result.condition_updates.last.assessed_rating).to eq(original_condition_rating)
      expect(result.service_status_updates.count).to eq(1)
      expect(result.service_status_updates.last.service_status_type_id).to eq(original_service_status_type_id)
    end
  end

  describe "with no serial numbers, condition updates or service status updates" do
    before(:each) { dispose!(source, sales_proceeds: 500) }

    it "does not create any serial number, condition update or service status update copies" do
      expect(source.serial_numbers.count).to eq(0)
      expect(source.condition_updates.count).to eq(0)
      expect(source.service_status_updates.count).to eq(0)

      result = source.transfer(target_org.id)

      expect(result).to be_persisted
      expect(result.serial_numbers.count).to eq(0)
      expect(result.condition_updates.count).to eq(0)
      expect(result.service_status_updates.count).to eq(0)
    end
  end
end
