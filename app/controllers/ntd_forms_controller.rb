class NtdFormsController < FormAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Forms", :forms_path

  # Include the fiscal year mixin
  include FiscalYear

  before_action :get_form,  :except =>  [:index, :create, :new, :download_file]

  INDEX_KEY_LIST_VAR          = "ntd_forms_key_list_cache_var"

  def index

    add_breadcrumb @form_type.name, form_path(@form_type)
    @fiscal_years = get_fiscal_years

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
    @fiscal_year = params[:fiscal_year]
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

    add_breadcrumb "New"

    @form = NtdForm.new

    @fiscal_years = get_fiscal_years

  end

  def create

    params[:ntd_form][:start_date] = reformat_date(params[:ntd_form][:start_date]) unless params[:ntd_form][:start_date].blank?
    params[:ntd_form][:end_date] = reformat_date(params[:ntd_form][:end_date]) unless params[:ntd_form][:end_date].blank?

    @form = NtdForm.new(form_params)
    @form.form = @form_type

    if @form.save
      redirect_to form_ntd_form_steps_url @form_type, @form
    else
      render :new
    end
  end

  def edit

    redirect_to form_ntd_form_steps_url @form_type, @form

  end

  def destroy

    @form.destroy
    notify_user(:notice, "Form was successfully removed.")
    respond_to do |format|
      format.html { redirect_to form_ntd_forms_url(@form_type) }
      format.json { head :no_content }
    end
  end

  def generate

    add_breadcrumb @form_type.name, form_path(@form_type)
    add_breadcrumb @form, form_ntd_form_path(@form_type, @form)
    add_breadcrumb 'Generate', generate_form_ntd_form_path(@form_type, @form)

    # Find out which builder is used to construct the template and create an instance
    builder = DirEntInvTemplateBuilder.new(:ntd_form => @form, :organization_list => [@form.organization_id])

    # Generate the spreadsheet. This returns a StringIO that has been rewound
    stream = builder.build

    # Save the template to a temporary file and render a success/download view
    file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
    ObjectSpace.undefine_finalizer(file)
    #You can uncomment this line when debugging locally to prevent Tempfile from disappearing before download.
    @filepath = file.path
    @filename = "#{@form.organization.short_name}_DirEntInv_#{Date.today}.xlsx"
    begin
      file << stream.string
    rescue => ex
      Rails.logger.warn ex
    ensure
      file.close
    end
    # Ensure you're cleaning up appropriately...something wonky happened with
    # Tempfiles not disappearing during testing
    respond_to do |format|
      format.js
      format.html
    end
  end

  def download_file
    # Send it to the user
    filename = params[:filename]
    filepath = params[:filepath]
    data = File.read(filepath)
    send_data data, :filename => filename, :type => "application/vnd.ms-excel"
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
