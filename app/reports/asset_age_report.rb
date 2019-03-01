class AssetAgeReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization_id_list, params)

    # Check to see if we got an asset type to sub select on
    if params[:class_filter_type] 
      report_filter_type = params[:class_filter_type].to_i
    else
      report_filter_type = 0
    end
    
    a = []
    asset_counts = []
    table_labels = ['Years']

    classes = []

    if report_filter_type > 0
      classes  = FtaAssetClass.where(id: report_filter_type)
    else
      classes = FtaAssetClass.all 
    end

    classes.each do |ac|
      count = TransitAsset.where(organization_id: organization_id_list, fta_asset_class: ac).count
      asset_counts << count
      table_labels << ac.name
    end
            
    # get the bucket for MAX_YEARS+ years old
    counts = []
    counts << "< 1"
    manufacture_year = 0.year.ago.year
    classes.each do |cla|
      counts << TransitAsset.where(organization_id: organization_id_list, fta_asset_class: cla, manufacture_year: manufacture_year).count
    end
    a << counts


    (1..MAX_REPORTING_YEARS).each do |year|
      counts = []
      counts << "#{year}"
      manufacture_year = year.year.ago.year
      classes.each do |cla|
        counts << TransitAsset.where(organization_id: organization_id_list, fta_asset_class: cla, manufacture_year: manufacture_year).count
      end
      a << counts
    end

    # get the bucket for MAX_YEARS+ years old
    #year = MAX_REPORTING_YEARS
    #counts = []
    #counts << "> #{year}"
    #manufacture_year = MAX_REPORTING_YEARS.year.ago.year
    #classes.each do |cla|
    #  counts << TransitAsset.where(organization_id: organization_id_list, fta_asset_class: cla).where("manufacture_year > manufacture_year").count
    #end
    #a << counts

    puts a.ai
        
    return {data: a, labels: table_labels, table_labels: table_labels, table_data: a, chart_labels: table_labels, chart_data: a, formats: [:integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer, :integer]}

  end


  def get_classes 
    class_types = []
    FtaAssetClass.active.each do |ac|
      class_types << ["#{ac.fta_asset_category.name}: #{ac.name}", ac.id]
     end
    return class_types
  end
  
end
