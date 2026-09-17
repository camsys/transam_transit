FactoryBot.define do
  factory :infrastructure do
    sequence(:asset_tag) { |n| "INFTAG#{n}" }
    purchase_cost { 100 }
    purchase_date { Date.today - 100.days }
    purchased_new { false }
    in_service_date { Date.today - 99.days }
    policy_replacement_year { Date.today.year + 20 }

    asset_subtype_id { AssetSubtype.find_by(name: "Bridge").id }

    # Infrastructure itself has no dedicated FtaAssetClass row (see the report accompanying
    # this factory) -- only its three Ruby subclasses (Guideway/PowerSignal/Track) do, each
    # scoped by its own default_scope on fta_asset_class. This factory builds a bare
    # `Infrastructure`, not one of those subclasses, but still needs a valid fta_asset_class
    # under the "Infrastructure" category to satisfy TransitAsset's presence validation, so it
    # borrows "guideway". Building via this factory will therefore also be visible to
    # `Guideway.all` (its default_scope matches on fta_asset_class, not on Ruby class), which
    # is a pre-existing structural fact, not something this factory introduces.
    fta_asset_class { FtaAssetClass.find_by(code: "guideway") }
    fta_asset_category { fta_asset_class.fta_asset_category }
    fta_type_type { "FtaGuidewayType" }
    fta_type_id { FtaGuidewayType.find_by(fta_asset_class_id: fta_asset_class.id, name: "At-Grade/Ballast (including Expressway)").id }

    # Picking the "Lat / Long" segment unit type sidesteps the from_line/from_segment/
    # infrastructure_chain_type_id/segment_unit conditional validations entirely (they only
    # apply for the other two segment-unit types), keeping this a minimal, working factory.
    infrastructure_segment_unit_type { InfrastructureSegmentUnitType.find_by(name: "Lat / Long") }
    infrastructure_segment_type { InfrastructureSegmentType.find_by(name: "Main Line") }

    # infrastructure_division_id/infrastructure_subdivision_id are always required and are
    # organization_id-scoped -- they cannot be picked from seed data, so a fresh division and
    # subdivision are created per build, scoped to whatever organization the caller passed in
    # (mirrors the `asset.organization` read already used in
    # spec/factories/concrete_assets.rb's `basic_asset_attributes` after(:build) hook).
    after(:build) do |asset|
      asset.infrastructure_division ||= InfrastructureDivision.create!(name: "Test Infrastructure Division", organization: asset.organization)
      asset.infrastructure_subdivision ||= InfrastructureSubdivision.create!(name: "Test Infrastructure Subdivision", organization: asset.organization)
    end
  end
end
