require 'rails_helper'

# TTPLAT-3072 P4 §4: TransamAsset.get_typed_asset's inner branch (transam_core bundled gem,
# transam_asset.rb:180-199). Measured state going into this pass: 183/185/187 each covered
# (hit 1,084 times in the P3-era probe); 188, 191 and 192 dark.
#
# No legacy counterpart - added from the TTPLAT-3072 coverage screen.
RSpec.describe TransamAsset, ".get_typed_asset" do
  # Line 188 (`asset = asset.send(seed_assoc).class_name(assets: asset).constantize.find_by(...)`)
  # is reached when a saved asset's `fta_asset_class.class_name(assets:)` disagrees with the
  # asset's own Ruby class. P1's `:infrastructure` factory produces exactly that state as a
  # genuine, non-invented lifecycle fact, not a contrived one: it builds a bare `Infrastructure`
  # (Ruby class) against the "guideway" FtaAssetClass row (see the factory's own comment,
  # spec/factories/infrastructures.rb) because Infrastructure itself has no dedicated FtaAssetClass
  # row -- only its three Ruby subclasses (Guideway/PowerSignal/Track) do. `Guideway`
  # (app/models/guideway.rb) is `class Guideway < Infrastructure` with
  # `default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'Guideway')) }` --
  # scoped on `fta_asset_class`, not on a Rails STI `type` column or actual Ruby class -- so a bare
  # `Infrastructure` row built against the "guideway" FtaAssetClass is, structurally, already a row
  # `Guideway.find_by` will match. Confirmed empirically (see below) rather than assumed.
  it "reassigns to the FtaAssetClass-named subclass when it disagrees with the asset's own Ruby class (line 188)" do
    organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: organization, parent: parent_policy)

    infra = create(:infrastructure, organization: organization)

    # The disagreement line 187 tests: the bare Ruby class vs. what FtaAssetClass#class_name
    # reports for this asset's category ("Infrastructure" -> reads the raw `class_name` column,
    # here "Guideway").
    expect(infra.class.to_s).to eq("Infrastructure")
    expect(infra.fta_asset_class.class_name(assets: infra)).to eq("Guideway")

    # and_call_original coverage proof (TTPLAT-3072 §5, mechanism 1): proves transit's suite
    # reaches this exact transam_core class method, defined only in the bundled gem.
    expect(TransamAsset).to receive(:get_typed_asset).at_least(:once).and_call_original

    result = TransamAsset.get_typed_asset(infra.transam_asset)

    expect(result).to be_a(Guideway)
    expect(result.object_key).to eq(infra.object_key)
  end

  # Lines 191-192 (the `rescue ArgumentError` branch: `class_name` called with no `assets:`
  # keyword) are checked against the mirror brief's rule, not built. Reaching them needs a seed
  # class whose `class_name` method raises ArgumentError when called *with* the `assets:` keyword.
  #
  # Checked, not assumed: `FtaAssetClass#class_name(opts: {}, assets: nil)` (app/models/fta_asset_class.rb)
  # gives both keyword arguments defaults, so calling it with `assets: asset` never raises
  # ArgumentError -- confirmed directly below. Every real, shipped asset type this app ever
  # constructs (ServiceVehicle, RevenueVehicle, Facility, Infrastructure, CapitalEquipment, and
  # their components) resolves through `TransitAsset`, whose own `asset_seed_class_name` override
  # ("FtaAssetClass", transit_asset.rb) is inherited by all of them via the `acts_as`
  # class-attribute mechanism -- confirmed directly below for the three name-checked here. The only
  # class in either repo whose `asset_seed_class_name` is still the bundled-gem default
  # ("AssetType") is a bare, unspecialized `TransamAsset` -- and `AssetType`'s `class_name` *is*
  # exactly the kind of zero-argument method the branch needs (a plain attribute reader, no
  # override in either repo), confirmed to raise ArgumentError when called with `assets:` below.
  # But no code path in this app ever asks `get_typed_asset` to resolve a `very_specific` asset
  # that bottoms out at plain `TransamAsset` rather than a `TransitAsset` descendant -- every
  # survivor type transit creates is `TransitAsset`-based. Reaching 191-192 for real would mean
  # constructing an asset type outside that hierarchy, which the mirror brief's rule rules out:
  # this is the "requires inventing a class the repo doesn't contain" side, not the "reachable in
  # the object's real lifecycle" side. Not built, per that rule and per TTPLAT-3072 §0/§7's explicit
  # instruction not to invent a class or state to reach a dark branch.
  it "documents why the ArgumentError branch (lines 191-192) is not reachable without inventing a class" do
    infra = build(:infrastructure)

    expect(FtaAssetClass.instance_method(:class_name).parameters).to include([:key, :opts], [:key, :assets])
    expect { FtaAssetClass.find_by(code: "guideway").class_name(assets: infra) }.not_to raise_error

    expect(TransitAsset.asset_seed_class_name).to eq("FtaAssetClass")
    expect(ServiceVehicle.asset_seed_class_name).to eq("FtaAssetClass")
    expect(RevenueVehicle.asset_seed_class_name).to eq("FtaAssetClass")
    expect(Facility.asset_seed_class_name).to eq("FtaAssetClass")
    expect(Infrastructure.asset_seed_class_name).to eq("FtaAssetClass")

    # The bundled-gem default -- what a bare, unspecialized TransamAsset (never produced by any
    # real code path in this app) would still report.
    expect(TransamAsset.asset_seed_class_name).to eq("AssetType")
    expect { AssetType.new.class_name(assets: infra) }.to raise_error(ArgumentError)
  end
end
