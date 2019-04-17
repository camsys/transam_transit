class NtdFormsController < FormAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Forms", :forms_path

  # Include the fiscal year mixin
  include FiscalYear

  before_action :get_form,  :except =>  [:index, :create, :new]

  INDEX_KEY_LIST_VAR          = "ntd_forms_key_list_cache_var"

  def index

    add_breadcrumb @form_type.name, form_path(@form_type)
    @fiscal_years = get_fiscal_years(Date.today-9.years,10)

     # Start to set up the query
    conditions  = []
    values      = []

    # Check to see if we got an organization to sub select on.
    @org_filter = params[:org_id]
    conditions << 'organization_id IN (?)'
    if @org_filter.blank?
      values << @organization_list
    else
      @org_filter = @org_filter.to_i
      values << [@org_filter]
    end

    # See if we got search
    @fiscal_year = params[:fiscal_year] || (current_fiscal_year_year - 1)
    unless @fiscal_year.blank?
      @fiscal_year = @fiscal_year.to_i
      conditions << 'fy_year = ?'
      values << @fiscal_year
    end

    @forms = NtdForm.where(conditions.join(' AND '), *values).order(:fy_year)

    unless params[:format] == 'xls'
      # cache the set of object keys in case we need them later
      cache_list(@forms, INDEX_KEY_LIST_VAR)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @forms }
      format.xls
    end
  end

  def show

    add_breadcrumb @form_type.name, form_path(@form_type)
    add_breadcrumb @form

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@form, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" :  form_ntd_form_path(@form_type, @prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : form_ntd_form_path(@form_type, @next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @form }
    end
  end


  def new

    add_breadcrumb @form_type.name, form_path(@form_type)
    add_breadcrumb "New"

    @form = NtdForm.new
    @form.fy_year = params[:fiscal_year] if params[:fiscal_year]
    @form.reporter_name = current_user.name
    @form.reporter_title = current_user.title
    @form.reporter_department = nil
    @form.reporter_email = current_user.email
    @form.reporter_phone = current_user.phone
    @form.reporter_phone_ext = current_user.phone_ext

    @fiscal_years = get_fiscal_years

  end

  def create

    params[:ntd_form][:start_date] = reformat_date(params[:ntd_form][:start_date]) unless params[:ntd_form][:start_date].blank?
    params[:ntd_form][:end_date] = reformat_date(params[:ntd_form][:end_date]) unless params[:ntd_form][:end_date].blank?

    @form = NtdForm.new(form_params)
    @form.form = @form_type
    @form.creator = current_user

    if @form.save
      @report = NtdReport.create(ntd_form: @form, creator: current_user, state: @form.state)
      reporting_service = NtdReportingService.new(report: @report)

      @report.ntd_revenue_vehicle_fleets = reporting_service.revenue_vehicle_fleets(Organization.where(id: @form.organization_id))
      @report.ntd_service_vehicle_fleets = reporting_service.service_vehicle_fleets(Organization.where(id: @form.organization_id))
      @report.ntd_facilities = reporting_service.facilities(Organization.where(id: @form.organization_id))
      @report.ntd_infrastructures = reporting_service.infrastructures(Organization.where(id: @form.organization_id))
      @report.ntd_performance_measures = reporting_service.performance_measures(Organization.where(id: @form.organization_id))

      redirect_to form_ntd_form_path(@form_type, @form)
    else
      render :new
    end
  end

  def edit

    add_breadcrumb @form_type.name, form_path(@form_type)
    add_breadcrumb @form, form_ntd_form_path(@form_type, @form)
    add_breadcrumb 'Update', edit_form_ntd_form_path(@form_type, @form)

  end

  def update
    @form.updator = current_user

    if @form.update(form_params)
      redirect_to form_ntd_form_path(@form_type, @form), notice: 'NTD Form was successfully updated.'
    else
      render :edit
    end
  end

  def destroy

    @form.destroy
    notify_user(:notice, "Form was successfully removed.")
    respond_to do |format|
      format.html { redirect_to form_ntd_forms_url(@form_type) }
      format.json { head :no_content }
    end
  end

  protected


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:ntd_form).permit(NtdForm.allowable_params)
  end

  def reformat_date(date_str)
    form_date = Date.strptime(date_str, '%m/%d/%Y')
    return form_date.strftime('%Y-%m-%d')
  end

  def get_form
    # See if it is our project
    @form = NtdForm.find_by(:object_key => params[:id]) unless params[:id].nil?
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @form.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(form_ntd_forms_url(@form_type))
      return
    end
  end

end
