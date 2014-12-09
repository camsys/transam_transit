class AssetDispositionReport < AbstractReport

  # include the fiscal year mixin
  include FiscalYear

  def initialize(attributes = {})
    super(attributes)
  end

  # returns summary of count and cost for assets to be disposed by fiscal year, type, and subtype
  def get_data(organization_id_list, params)

    # Check to see if we got an asset type to filter by
    asset_type_id =  params[:asset_type_id] ? params[:asset_type_id].to_i : 0

    max_fy = Asset.maximum(:scheduled_replacement_year)

    # labels
    labels_summary = ['Fiscal Year', 'Type', 'Subtype', 'Count', 'Total Cost']

    fiscal_years = current_fiscal_year_year..max_fy

    # summary table of report
    disposition_summary = Array.new
    fiscal_years.each do |fy|
      if asset_type_id > 0
        asset_subtypes = AssetSubtype.where('asset_type_id = ?', asset_type_id)
      else
        asset_subtypes = AssetSubtype.all.order(:asset_type_id)
      end
      asset_subtypes.each do |asset_subtype|
        disposable = Asset.disposition_list(fy,asset_subtype.asset_type.id,asset_subtype.id)
        if disposable.count > 0 || disposable.sum(:scheduled_replacement_cost) > 0
          data = {
            :fiscal_year => fiscal_year(fy),
            :asset_type => asset_subtype.asset_type.name,
            :asset_subtype => asset_subtype.name,
            :replacement_number => disposable.count,
            :total_cost => disposable.sum(:scheduled_replacement_cost)
          }

          disposition_summary << data
        end
      end
    end




    return {:labels_summary => labels_summary, :fiscal_years => fiscal_years, :data_summary => disposition_summary}

  end

end
