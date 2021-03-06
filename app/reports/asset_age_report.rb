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
      table_labels << ac.name #unless count == 0
    end
            
    # get the bucket for MAX_YEARS+ years old
    counts = []
    counts << "< 1"
    manufacture_year = 0.year.ago.year
    classes.each_with_index do |cla, idx|
      counts << TransitAsset.where(organization_id: organization_id_list, fta_asset_class: cla).where('YEAR(in_service_date) = ?', manufacture_year).count #unless asset_counts[idx] == 0
    end
    a << counts


    (1..MAX_REPORTING_YEARS).each do |year|
      counts = []
      counts << "#{year}"
      manufacture_year = year.year.ago.year
      classes.each_with_index do |cla, idx|
        counts << TransitAsset.where(organization_id: organization_id_list, fta_asset_class: cla).where('YEAR(in_service_date) = ?', manufacture_year).count #unless asset_counts[idx] == 0
      end
      a << counts
    end

    # get the bucket for MAX_YEARS+ years old
    year = MAX_REPORTING_YEARS
    counts = []
    counts << "> #{year}"
    manufacture_year = MAX_REPORTING_YEARS.year.ago.year
    classes.each do |cla|
      counts << TransitAsset.where(organization_id: organization_id_list, fta_asset_class: cla).where('YEAR(in_service_date) < ?', manufacture_year).count #unless asset_counts[idx] == 0
    end
    a << counts

    formats = Array.new(classes.count + 1){ |x| :integer }



    subheader = 'Age Count <a class="transam-popover" data-container="body" data-content="<p>Based on <i>In Service Date</i> of asset + 365 days.</p><p>e.g. <i>In Service Date</i> + 364 days = <1 year; <i>In Service Date</i> + 365 days = 1 year</p>" data-html="true" data-placement="bottom" data-title="Age" data-toggle="popover" tabindex="0" data-original-title="" title=""><i class="fa fa-info-circle text-info"></i></a>'

    return {data: a, labels: table_labels, table_subheader: subheader, table_labels: table_labels, table_data: a, chart_labels: table_labels, chart_data: a, formats: formats}

  end


  def get_classes 
    class_types = []
    FtaAssetClass.active.each do |ac|
      class_types << ["#{ac.fta_asset_category.name} : #{ac.name}", ac.id]
     end
    return class_types

  end
  
end
