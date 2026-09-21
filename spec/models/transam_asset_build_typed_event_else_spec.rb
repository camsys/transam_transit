require 'rails_helper'

# TTPLAT-3072 P5 §4: TransamAsset#build_typed_event's `else` branch (transam_core bundled gem,
# transam_asset.rb:392), 1 relevant line, 0 covered going into this pass.
#
# No legacy counterpart - added from the TTPLAT-3072 coverage screen.
#
# P4 (§4/§3 of that pass) worked out the trigger and proved it reachable with a scratch probe
# (deleted before finishing, per §8): the `else` fires when
# `typed_asset.class.superclass.name != "TransamAssetRecord"` -- i.e. a survivor TWO inheritance
# levels below TransamAssetRecord, not one. ServiceVehicle/RevenueVehicle/Facility/Infrastructure
# are direct subclasses (`class X < TransamAssetRecord`) and always take the `if`.
# `Guideway < Infrastructure < TransamAssetRecord` is exactly two deep. P1's `:infrastructure`
# factory already produces a row `Guideway.find_by(object_key: ...)` matches, because Guideway's
# `default_scope` (app/models/guideway.rb:5) filters on `fta_asset_class`, not on a Rails STI
# `type` column or the row's actual Ruby class.
#
# Route chosen: model-level example, reusing the same :infrastructure/Guideway fixture path §4
# of P4 already established and P1 built, rather than driving it through
# AssetEventsController#create or Api::V1::AssetEventsController#create (both real,
# transit-unoverridden call sites P4 found -- gem's asset_events_controller.rb:122 and
# api/v1/asset_events_controller.rb:39; the brief that fed P4 had wrongly said the only call
# sites were the eleven file-handler loaders). A model-level example is explicitly sanctioned by
# this pass's brief and needs no new spec layer (spec/controllers/ exists here, but a full
# controller-request example would need session/params/authorization setup this line's coverage
# doesn't need).
RSpec.describe TransamAsset, "#build_typed_event" do
  it "builds the typed event through the two-levels-deep branch (line 392) for a Guideway" do
    parent_policy = create(:parent_policy)
    organization = create(:organization)
    create(:policy, organization: organization, parent: parent_policy)

    infra = create(:infrastructure, organization: organization)
    guideway = Guideway.find_by(object_key: infra.object_key)

    # Confirms the trigger condition directly, rather than assuming P4's finding still holds:
    # Guideway sits two levels below TransamAssetRecord, so the `else` (not the `if`) executes.
    expect(guideway.class.superclass.name).not_to eq("TransamAssetRecord")
    expect(guideway.event_classes).to include(ConditionUpdateEvent)

    # and_call_original coverage proof (TTPLAT-3072 §6, mechanism 1): proves transit's suite
    # reaches this exact transam_core instance method, defined only in the bundled gem, through
    # its two-levels-deep branch specifically (not just the `if` branch every other survivor
    # fixture already exercises elsewhere in the suite).
    expect(guideway.transam_asset).to receive(:build_typed_event).at_least(:once).and_call_original

    result = guideway.build_typed_event(ConditionUpdateEvent)

    expect(result).to be_a(ConditionUpdateEvent)
    expect(result).not_to be_persisted
    expect(result.transam_asset_type).to eq("TransamAsset")
    expect(result.transam_asset_id).to eq(guideway.transam_asset.id)
  end
end
