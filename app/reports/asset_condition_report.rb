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

    # Check to see if we got an class type to sub select on
    if params[:class_filter_type] 
      class_filter_type = params[:class_filter_type].to_i
    else
      class_filter_type = 0
    end
            
    table_data = [] 
    chart_data = []
    table_labels = ['Condition', 'Category', 'Class', 'Count']
    chart_labels = ['Condition', 'Count']

    conditions = ConditionType.all
    classes = (class_filter_type > 0) ? FtaAssetClass.where(id: class_filter_type) : FtaAssetClass.all 

    # Build Table Data
    conditions.each do |x|
      classes.each do |cla|
        count = TransitAsset.joins(:asset).where('organization_id IN (?) AND assets.reported_condition_type_id = ?', organization_id_list, x.id).where(fta_asset_class: cla).count
        table_data << [x.name, cla.fta_asset_category.name, cla.name, count]
      end
    end

    # Build Chart Data
    conditions.each do |x|
      if classes.count == 0
        count = TransitAsset.joins(:asset).where('organization_id IN (?) AND assets.reported_condition_type_id = ?', organization_id_list, x.id).count
      else
        count = TransitAsset.joins(:asset).where('organization_id IN (?) AND assets.reported_condition_type_id = ?', organization_id_list, x.id).where(fta_asset_class: classes).count
      end
      chart_data << [x.name, count]
    end
        
    return {data: table_data, labels: table_labels, table_labels: table_labels, table_data: table_data, chart_labels: chart_labels, chart_data: chart_data, formats: [:string, :string, :string, :integer]}

  end

  def get_classes 
    class_types = []
    FtaAssetClass.active.each do |ac|
      class_types << ["#{ac.fta_asset_category.name}: #{ac.name}", ac.id]
     end
    return class_types
  end
  
end
