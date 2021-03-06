qc = QueryCategory.find_by(name: 'Identification & Classification')

# create categorization db view
view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_assets_category_view AS
    select transam_assets.id as transam_asset_id, (case when component_subtypes.name is not NULL then 'Sub-Component' when component_types.name is not NULL then 'Component' ELSE 'Primary' END) as categorization_name,
    (case when component_subtypes.name is not NULL then component_subtypes.name when component_types.name is not NULL then component_types.name ELSE NULL END) as component_type_subtype_name
    FROM transam_assets
    LEFT JOIN transit_assets ON transit_assets.id = transam_assets.transam_assetible_id
    LEFT JOIN facilities on facilities.id = transit_assets.transit_assetible_id and transit_assets.transit_assetible_type = 'Facility'
    LEFT JOIN infrastructures on infrastructures.id = transit_assets.transit_assetible_id and transit_assets.transit_assetible_type = 'Infrastructure'
    LEFT JOIN transit_components ON transit_components.id = transit_assets.transit_assetible_id
      AND transit_assets.transit_assetible_type = 'TransitComponent'
    LEFT JOIN component_types ON component_types.id = transit_components.component_type_id 
    LEFT JOIN component_subtypes on component_subtypes.id = transit_components.component_subtype_id 
    WHERE transam_assets.transam_assetible_type = 'TransitAsset' AND ( facilities.id > 0 OR infrastructures.id > 0 OR transit_assets.fta_asset_class_id IN ( SELECT fta_asset_classes.id FROM fta_asset_classes WHERE fta_asset_classes.class_name IN ('Facility', 'Guideway', 'PowerSignal', 'Track')));
SQL

ActiveRecord::Base.connection.execute view_sql

data_table = QueryAssetClass.find_or_create_by(
  table_name: 'transit_assets_category_view',
  transam_assets_join: "LEFT JOIN transit_assets_category_view on transit_assets_category_view.transam_asset_id = transam_assets.id"
)

# query field
qf = QueryField.find_or_create_by(
  name: 'categorization_name',
  label: 'Categorization',
  filter_type: 'multi_select',
  query_category: qc
)
qf.query_asset_classes = [data_table]