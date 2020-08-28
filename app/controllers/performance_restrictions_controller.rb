class PerformanceRestrictionsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  before_action :reformat_date_fields, only: [:index]

  def index
    
    asset_event_type = AssetEventType.find_by(class_name: 'PerformanceRestrictionUpdateEvent')
    asset_event_klass = asset_event_type.class_name.constantize
    @active_restrictions = asset_event_klass.running
    @inactive_restrictions = asset_event_klass.expired

    add_breadcrumb "Performance Restrictions"
 
    respond_to do |format|
      format.html
    end

  end

  private

  def reformat_date_fields
    params[:start_datetime] = reformat_date(params[:start_datetime]) unless params[:start_datetime].blank?
    params[:end_datetime] = reformat_date(params[:end_datetime]) unless params[:end_datetime].blank?
  end

  def reformat_date(date_str)
    form_date = Date.strptime(date_str, '%m/%d/%Y')
    return form_date.strftime('%Y-%m-%d')
  end

end
