require 'rails_helper'

# TTPLAT-3072 P5 §2 (M9): survivor type resolution and policy. Legacy source: core
# asset_spec.rb:194-213 (#type_of?) and the #policy example at :385-403 (gem line numbers,
# transam_core-baebbb3f6d68).
#
# Three targets, two of which are mixins injected at boot by SystemConfigExtension and appear
# nowhere in transam_asset.rb's own source (see systemconfigextension-mechanism.md):
#   - TransamAssetRecord#type_of? (transam_asset_record.rb:26) -- plain Ruby inheritance,
#     ServiceVehicle < TransamAssetRecord directly.
#   - PolicyAware#policy (policy_aware.rb:27) -- injected into TransamAsset, reached from a
#     ServiceVehicle instance via the acts_as delegation chain (ServiceVehicle acts_as
#     :transit_asset -> TransitAsset acts_as :transam_asset -> TransamAsset).
#   - ReplaceableAsset#expected_useful_life (replaceable_asset.rb:126) -- also injected into
#     TransamAsset the same way.
RSpec.describe "survivor type resolution and policy (M9)" do

  describe "TransamAssetRecord#type_of?" do
    # Mirrors the behavior asserted by core asset_spec.rb:195-197, which tested Asset#type_of?
    # (asset.rb:653). Asset#type_of? and TransamAssetRecord#type_of? (transam_asset_record.rb:26)
    # have an identical body (`self.class.ancestors.include?(type.to_s.classify.constantize)
    # rescue false`) but are independently defined on disjoint classes -- Asset and
    # TransamAssetRecord share only ActiveRecord::Base. Covering one credits the other with
    # nothing; this exercises TransamAssetRecord#type_of? directly, confirmed below to resolve
    # via ServiceVehicle's own (real, single-branch) inheritance from TransamAssetRecord, not
    # through the acts_as delegation the other two targets in this file need.
    it "only looks up the ancestor chain, not sibling survivor classes" do
      service_vehicle = build(:service_vehicle)

      expect(service_vehicle.method(:type_of?).owner).to eq(TransamAssetRecord)
      # RevenueVehicle is a sibling subclass of TransamAssetRecord, not an ancestor of
      # ServiceVehicle -- the same shape as the legacy example's :geolocatable_asset check.
      expect(service_vehicle.type_of?(:revenue_vehicle)).to be false
    end

    # Mirrors the behavior asserted by core asset_spec.rb:200-202, which tested Asset#type_of?
    # (asset.rb:653); this covers TransamAssetRecord#type_of? (transam_asset_record.rb:26), an
    # independent definition on the disjoint survivor tree (see the label above).
    it "returns true when passed a symbol, string or classname that is an ancestor" do
      service_vehicle = build(:service_vehicle)

      expect(service_vehicle.type_of?(:transam_asset_record)).to be true
      expect(service_vehicle.type_of?("transam_asset_record")).to be true
      expect(service_vehicle.type_of?(TransamAssetRecord)).to be true
      expect(service_vehicle.type_of?(:service_vehicle)).to be true
    end
  end

  describe "PolicyAware#policy" do
    # Mirrors the behavior asserted by core asset_spec.rb:385-403, which tested Asset#policy
    # (asset.rb:785, `Organization.get_typed_organization(organization).get_policy`); this
    # covers PolicyAware#policy (policy_aware.rb:27, `organization.get_policy`), an independent
    # definition injected into TransamAsset by SystemConfigExtension (transit's
    # db/data_migrations register TransamAsset<-PolicyAware) -- not literally inherited, and not
    # even textually identical to Asset#policy (Asset#policy upcasts the organization first;
    # PolicyAware#policy calls organization.get_policy directly, which itself upcasts). Same
    # behavior, different method object on the disjoint tree.
    #
    # Confirmed to resolve on a real survivor instance below (not assumed): PolicyAware is not
    # visible anywhere in transam_asset.rb's own source.
    it "resolves to the organization's own policy, not its parent's, mirroring the legacy tree-resolution example" do
      expect(TransamAsset.ancestors).to include(PolicyAware)
      expect(TransamAsset.instance_method(:policy).owner).to eq(PolicyAware)

      parent_organization = create(:organization)
      parent_policy = create(:parent_policy, organization: parent_organization,
                              interest_rate: 0.10, condition_threshold: 4.0)

      organization = create(:organization)
      own_policy = create(:policy, organization: organization, parent: parent_policy,
                           interest_rate: 0.07, condition_threshold: 3.0)

      service_vehicle = create(:service_vehicle, organization: organization)

      # and_call_original coverage proof (TTPLAT-3072 P4/P5 §6, mechanism 1): proves transit's
      # suite reaches this exact transam_core instance method, defined only in the bundled gem
      # and injected at boot -- not a transit override. Stubbed on the concrete TransamAsset
      # instance itself rather than via expect_any_instance_of(PolicyAware): PolicyAware is a
      # module reached here through a two-level acts_as delegation chain
      # (ServiceVehicle -> TransitAsset -> TransamAsset), and any_instance_of on the module
      # recurses the delegation's own method_missing into a SystemStackError (confirmed by
      # trying it first).
      expect(service_vehicle.transam_asset).to receive(:policy).at_least(:once).and_call_original

      resolved = service_vehicle.policy

      # Confirms the acts_as delegation itself actually reaches the survivor's TransamAsset row.
      expect(resolved).to eq(service_vehicle.transam_asset.policy)
      expect(resolved).to eq(own_policy)
      expect(resolved).not_to eq(parent_policy)
      expect(resolved.interest_rate.to_f).to eq(0.07)
      expect(resolved.condition_threshold).to eq(3.0)
    end
  end

  describe "ReplaceableAsset#expected_useful_life" do
    # No legacy counterpart - added from the TTPLAT-3072 coverage screen.
    #
    # The M-list pairs this with core asset_spec.rb:212-213 ("sets expected useful life if
    # policy and policy item exists"), but that example's body is empty (`it '...' do end`,
    # confirmed by reading the file directly) -- it asserts nothing and has never tested any
    # behavior. Separately, even a hypothetical live version of that example would be testing
    # Asset#expected_useful_life= (asset.rb:673), a plain integer-sanitizing SETTER
    # (`self[:expected_useful_life] = sanitize_to_int(num)`) -- not the same behavior as
    # ReplaceableAsset#expected_useful_life (replaceable_asset.rb:126), a computed GETTER that
    # derives a value from the policy analyzer. The M-list pairing is spurious on both counts;
    # labelled per §5 as having no genuine legacy counterpart rather than a false "mirrors".
    #
    # Confirmed to resolve on a real survivor instance below (not assumed): ReplaceableAsset is
    # not visible anywhere in transam_asset.rb's own source.
    it "computes the used-purchase minimum service life from the policy chain for a used asset" do
      expect(TransamAsset.ancestors).to include(ReplaceableAsset)
      expect(TransamAsset.instance_method(:expected_useful_life).owner).to eq(ReplaceableAsset)

      parent_policy = create(:parent_policy)
      organization = create(:organization)
      create(:policy, organization: organization, parent: parent_policy)

      # :service_vehicle defaults purchased_new to false, so this exercises the
      # get_min_used_purchase_service_life_months branch (replaceable_asset.rb:127).
      service_vehicle = create(:service_vehicle, organization: organization, purchased_new: false)

      # and_call_original coverage proof (TTPLAT-3072 P4/P5 §6, mechanism 1) -- stubbed on the
      # concrete TransamAsset instance rather than expect_any_instance_of(ReplaceableAsset), for
      # the same reason as the #policy example above (module + acts_as delegation recurses).
      expect(service_vehicle.transam_asset).to receive(:expected_useful_life).at_least(:once).and_call_original

      result = service_vehicle.expected_useful_life

      expected_rule_value = service_vehicle.policy
                                            .find_or_create_asset_subtype_rule(service_vehicle.asset_subtype)
                                            .min_used_purchase_service_life_months
      expect(result).to eq(expected_rule_value)
    end
  end
end
