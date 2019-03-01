class AssetConditionReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization_id_list, params)

    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end
            
    table_data = [] 
    chart_data = []
    table_labels = ['Condition', 'Category', 'Class', 'Count']
    chart_labels = ['Condition', 'Count']

    conditions = ConditionType.all
    categories = (report_filter_type > 0) ? FtaAssetCategory.where(id: report_filter_type) : FtaAssetCategory.all
    classes = FtaAssetClass.all

    # Build Table Data
    conditions.each do |x|
      categories.each do |category|
        classes.each do |cla|
          count = TransitAsset.joins(:asset).where('organization_id IN (?) AND assets.reported_condition_type_id = ?', organization_id_list, x.id).where(fta_asset_category: category, fta_asset_class: cla).count
          table_data << [x.name, category.name, cla.name, count]
        end
      end
    end

    # Build Chart Data
    conditions.each do |x|
      count = TransitAsset.joins(:asset).where('organization_id IN (?) AND assets.reported_condition_type_id = ?', organization_id_list, x.id).count
      chart_data << [x.name, count]
    end
        
    return {data: table_data, labels: table_labels, table_labels: table_labels, table_data: table_data, chart_labels: chart_labels, chart_data: chart_data, formats: [:string, :string, :string, :integer]}

  end
  
end
