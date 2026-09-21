require 'rails_helper'

# TTPLAT-3072 P5 §3 (M5): survivor service-status / condition path -- RETARGETED.
#
# Legacy source: core asset_spec.rb:348-384 (gem transam_core-baebbb3f6d68); transit
# concrete_asset_spec.rb:146-183. The M-list names the target as "Asset#update_service_status /
# Asset#update_condition" (asset.rb:880/:902 in the gem). Gated per §3 before writing anything:
#
# 1. Confirmed absence across all THIRTEEN fenced repos (transam_core, transam_transit,
#    transam_audit, transam_accounting, transam_cpt, transam_spatial, transam_funding,
#    transam_reporting, transam_lib, transam_mms, transam_highway, transam_lrs, bpt), both
#    app/lib source and db/data_migrations: `update_service_status`/`update_condition` are
#    defined in exactly one place across the fence -- legacy Asset (asset.rb:880/:902). The one
#    other source hit, transam_mms's MaintenanceServiceOrdersController#update_service_status,
#    is an unrelated controller action on a different model (MaintenanceServiceOrder), not an
#    override. No db/data_migrations file in any of the 13 repos mentions either name. Absence
#    holds; per the M1 precedent this method genuinely has no survivor target.
#
# 2. What actually reflects service status / condition on a survivor, confirmed empirically
#    (not assumed) -- and NOT what this brief's own hypothesis guessed
#    (ServiceStatusUpdateEvent#update_asset / ConditionUpdateEvent#update_asset as callbacks
#    writing to stored columns). Checked directly:
#      - `transam_assets` (the survivor table) has NO service_status_date, service_status_type_id,
#        reported_condition_date, reported_condition_rating or reported_condition_type_id
#        columns at all -- confirmed against spec/dummy/db/schema.rb. Those columns exist only
#        on the legacy `assets` table.
#      - Transit's own ServiceStatusUpdateEvent#update_asset (app/models/service_status_update_event.rb:69,
#        this file wins over core's per codebase-notes §1.6 same-named-file shadowing) only
#        writes `fta_emergency_contingency_fleet` -- unrelated to service status/condition.
#      - ConditionUpdateEvent has no `update_asset` at all; its `after_save :check_policy`
#        (condition_update_event.rb) drives `check_policy_rule`/`update_asset_state`
#        (PolicyAware), which touch policy_replacement_year/scheduled_replacement_*, not
#        reported_condition_*.
#      - The actual mechanism is READ-THROUGH, not push: `TransamAsset#service_status_type`
#        (transam_asset.rb:449), `#reported_condition_date` (:463), `#reported_condition_rating`
#        (:471) and `#reported_condition_type` (:483) are plain getters that query the
#        `service_status_updates`/`condition_updates` associations live every time they are
#        called. Creating the event doesn't push a value onto the asset; it just becomes the
#        record these getters find. Confirmed with a throwaway probe spec (deleted) showing
#        `source.transam_asset.method(:reported_condition_rating).source_location` ==
#        [".../transam_core-baebbb3f6d68/app/models/transam_asset.rb", 471], and the same for
#        the other three at lines 449/463/483.
#      - There is NO survivor equivalent for `service_status_date` specifically: neither
#        `TransamAsset` nor any of its acts_as-delegating survivors (confirmed:
#        `respond_to?(:service_status_date)` is false on both) has any method or column by that
#        name. That one legacy-asserted value has no counterpart anywhere on the survivor side --
#        a genuine gap, reported as a candidate finding below, not fixed here (per §0).
#
# 3. Retargeted: M5 is written against the four read-through getters above, exercised by
#    creating the same events the legacy examples create and asserting the getters reflect them
#    -- as close a mirror of the legacy assertions as the survivor mechanism allows.
RSpec.describe "survivor service-status / condition path (M5, retargeted)" do
  before(:each) do
    parent_policy = create(:parent_policy)
    @organization = create(:organization)
    create(:policy, organization: @organization, parent: parent_policy)
  end

  # Mirrors the behavior asserted by core asset_spec.rb:348-355 ("`.update_service_status` works
  # as expected"), which tested Asset#update_service_status (asset.rb:880) pushing
  # service_status_date/service_status_type onto the asset after creating a
  # ServiceStatusUpdateEvent. There is no method of that name on the survivor tree (see the gate
  # above): this covers TransamAsset#service_status_type (transam_asset.rb:449), an independently
  # defined READ-THROUGH getter reached the same way -- by creating the event -- but computing
  # the value live from the association rather than being pushed onto a stored column.
  #
  # service_status_date is asserted separately, as absent: no survivor counterpart exists.
  describe "TransamAsset#service_status_type" do
    it "reflects the last service status update event's type once one is created" do
      service_vehicle = create(:service_vehicle, organization: @organization)
      expect(service_vehicle.transam_asset.service_status_updates.count).to eq(0)

      service_vehicle.service_status_updates.create!(attributes_for(:service_status_update_event))
      service_vehicle.reload

      # and_call_original coverage proof (TTPLAT-3072 §6, mechanism 1): proves transit's suite
      # reaches this exact transam_core instance method, defined only in the bundled gem.
      expect(service_vehicle.transam_asset).to receive(:service_status_type).at_least(:once).and_call_original

      expect(service_vehicle.service_status_updates.count).to eq(1)
      expect(service_vehicle.service_status_type).to eq(ServiceStatusType.find(2))

      # The gap: legacy also asserts persisted_buslike_asset.service_status_date == Date.today.
      # No survivor method or column by that name exists to mirror it against.
      expect(service_vehicle.respond_to?(:service_status_date)).to be false
      expect(service_vehicle.transam_asset.respond_to?(:service_status_date)).to be false
    end
  end

  # Mirrors the behavior asserted by core asset_spec.rb:367-374 ("`.update_condition` works as
  # expected"), which tested Asset#update_condition (asset.rb:902) pushing
  # reported_condition_date/reported_condition_rating/reported_condition_type onto the asset
  # after creating a ConditionUpdateEvent. There is no method of that name on the survivor tree
  # (see the gate above): this covers TransamAsset#reported_condition_date/_rating/_type
  # (transam_asset.rb:463/471/483), independently defined READ-THROUGH getters reached the same
  # way -- by creating the event -- but computed live from the association rather than pushed
  # onto stored columns.
  describe "TransamAsset#reported_condition_date / #reported_condition_rating / #reported_condition_type" do
    it "reflect the last condition update event's date, rating and derived type once one is created" do
      service_vehicle = create(:service_vehicle, organization: @organization)
      expect(service_vehicle.transam_asset.condition_updates.count).to eq(0)

      service_vehicle.condition_updates.create!(attributes_for(:condition_update_event))
      service_vehicle.reload

      # and_call_original coverage proof (TTPLAT-3072 §6, mechanism 1): proves transit's suite
      # reaches these exact transam_core instance methods, defined only in the bundled gem.
      expect(service_vehicle.transam_asset).to receive(:reported_condition_date).at_least(:once).and_call_original
      expect(service_vehicle.transam_asset).to receive(:reported_condition_rating).at_least(:once).and_call_original
      expect(service_vehicle.transam_asset).to receive(:reported_condition_type).at_least(:once).and_call_original

      expect(service_vehicle.condition_updates.count).to eq(1)
      expect(service_vehicle.reported_condition_date).to eq(Date.parse("2014-01-01"))
      expect(service_vehicle.reported_condition_rating).to eq(3)
      expect(service_vehicle.reported_condition_type).to eq(ConditionType.from_rating(3))
    end
  end
end
