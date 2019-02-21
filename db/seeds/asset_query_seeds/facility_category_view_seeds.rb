qc = QueryCategory.find_by(name: 'Identification & Classification')

# create vin db view
view_sql = <<-SQL
  CREATE OR REPLACE VIEW facility_category_view AS
    select transam_assets.id as transam_asset_id, (case when component_types.name is not NULL then 'Component' when component_subtypes.name is not NULL then 'Sub-Component' ELSE 'Primary Facility' END) as facility_category_name, 
    (case when component_types.name is not NULL then component_types.name when component_subtypes.name is not NULL then component_subtypes.name ELSE NULL END) as facility_component_type
    FROM transam_assets
    LEFT JOIN transit_assets ON transit_assets.id = transam_assets.transam_assetible_id
    LEFT JOIN facilities on facilities.id = transit_assets.transit_assetible_id and transit_assets.transit_assetible_type = 'Facility'
    LEFT JOIN transit_components ON transit_components.id = transit_assets.transit_assetible_id
      AND transit_assets.transit_assetible_type = 'TransitComponent'
    LEFT JOIN component_types ON component_types.id = transit_components.component_type_id 
    LEFT JOIN component_subtypes on component_subtypes.id = transit_components.component_subtype_id 
    WHERE transam_assets.transam_assetible_type = 'TransitAsset' AND ( facilities.id > 0 OR transit_assets.fta_asset_class_id IN ( SELECT fta_asset_classes.id FROM fta_asset_classes WHERE fta_asset_classes.class_name = 'Facility' ))
SQL

ActiveRecord::Base.connection.execute view_sql

data_table = QueryAssetClass.find_or_create_by(
  table_name: 'facility_category_view', 
  transam_assets_join: "LEFT JOIN facility_category_view on facility_category_view.transam_asset_id = transam_assets.id"
)

# query field
qf = QueryField.find_or_create_by(
  name: 'facility_category_name',
  label: 'Facility Categorization',
  filter_type: 'multi_select',
  query_category: qc
)
qf.query_asset_classes = [data_table]