class AddModelNameView < ActiveRecord::Migration[5.2]
  def change

    # Create a view that creates a single column combining manufacturer_model_name and other_manufacturer_model_name
    # The other_manufacturer_model_name will populate the clumn when other_manufacturer_model.name = "Other"
    # user_id, role_label
    my_view= <<-SQL
      CREATE OR REPLACE VIEW transam_assets_model_names AS
        SELECT
          ta.id AS transam_asset_id,
          mm.name as model_name,
          ta.other_manufacturer_model as other_model_name,
          CASE
            WHEN mm.name="Other" THEN ta.other_manufacturer_model
            ELSE mm.name
          END as combined_name
        FROM transam_assets AS ta
        LEFT JOIN manufacturer_models AS mm ON mm.id = ta.manufacturer_model_id;
    SQL
    ActiveRecord::Base.connection.execute my_view
  end
end
