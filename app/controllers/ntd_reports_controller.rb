class NtdReportsController < FormAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Forms", :forms_path

  # Include the fiscal year mixin
  include FiscalYear

  before_action :get_form
  before_action :get_report,  :except =>  [:create, :download_file]

  def create

    @report = NtdReport.new
    @report.ntd_form = @form
    @report.creator = current_user
    @report.state = @form.state

    if @report.save
      reporting_service = NtdReportingService.new(report: @report)

      @report.ntd_revenue_vehicle_fleets = reporting_service.revenue_vehicle_fleets(Organization.where(id: @form.organization_id))
      @report.ntd_service_vehicle_fleets = reporting_service.service_vehicle_fleets(Organization.where(id: @form.organization_id))
      @report.ntd_facilities = reporting_service.facilities(Organization.where(id: @form.organization_id))
      @report.ntd_infrastructures = reporting_service.infrastructures(Organization.where(id: @form.organization_id))
      @report.ntd_a20_summaries = reporting_service.generate_a20_summaries(Organization.where(id: @form.organization_id))
      @report.ntd_performance_measures = reporting_service.performance_measures(Organization.where(id: @form.organization_id))

      redirect_to form_ntd_form_url @form_type, @form
    else
      render :new
    end
  end

  def destroy

    @report.destroy
    notify_user(:notice, "Form was successfully removed.")
    respond_to do |format|
      format.html { redirect_to form_ntd_form_path(@form_type, @form) }
      format.json { head :no_content }
    end
  end

  def comments
    respond_to do |format|
      format.js
    end
  end

  def process_log
    respond_to do |format|
      format.js
    end
  end

  def generate

    puts @form 
    puts @form_type

    add_breadcrumb @form_type.name, form_path(@form_type)
    add_breadcrumb @form, form_ntd_form_path(@form_type, @form)
    add_breadcrumb 'Generate', generate_form_ntd_form_ntd_report_path(@form_type, @form, @report)

    # Find out which builder is used to construct the template and create an instance
    a15_builder = A15TemplateBuilder.new(:ntd_report => @report, :organization_list => [@report.ntd_form.organization_id])
    a35_builder = A35TemplateBuilder.new(:ntd_report => @report, :organization_list => [@report.ntd_form.organization_id])
    a20_builder = A20TemplateBuilder.new(:ntd_report => @report, :organization_list => [@report.ntd_form.organization_id])
    a90_builder = A90TemplateBuilder.new(:ntd_report => @report, :organization_list => [@report.ntd_form.organization_id])
    a90_builder_group = A90TemplateBuilder.new(:ntd_report => @report, :organization_list => [@report.ntd_form.organization_id], :is_group_report => true)


    # Generate the spreadsheet. This returns a StringIO that has been rewound
    a15_stream = a15_builder.build
    a35_stream = a35_builder.build
    a20_stream = a20_builder.build
    a90_stream = a90_builder.build
    a90_group_stream = a90_builder_group.build

    a30_zip_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
    ObjectSpace.undefine_finalizer(a30_zip_file)
    @a30_zip_filepath = a30_zip_file.path
    @a30_zip_filename = "#{@report.ntd_form.organization.short_name}_A30_#{Date.today}.zip"
    mode_tos_list = @report.ntd_revenue_vehicle_fleets.distinct.pluck(:fta_mode, :fta_service_type)

    begin
      Zip::OutputStream.open(a30_zip_file) { |zos| }

      Zip::File.open(@a30_zip_filepath, Zip::File::CREATE) do |zip|

        mode_tos_list.each do |mode_tos|
          a30_builder = A30TemplateBuilder.new(:ntd_report => @report, :organization_list => [@report.ntd_form.organization_id], :fta_mode_type => mode_tos[0], :fta_service_type => mode_tos[1])
          a30_stream = a30_builder.build

          if a30_stream.present?
            mode_tos_str = "#{mode_tos[0]} #{mode_tos[1]}"
            a30_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"

            ObjectSpace.undefine_finalizer(a30_file)
            a30_filepath = a30_file.path
            a30_filename = "#{@report.ntd_form.organization.short_name}_A30_#{mode_tos_str}_#{Date.today}.xlsx"
            begin
              a30_file << a30_stream.string
            rescue => ex
              Rails.logger.warn ex
            ensure
              a30_file.close
            end

            zip.add(a30_filename, a30_filepath)
          end
        end
      end

    ensure
      a30_zip_file.close
    end



    # Save the template to a temporary file and render a success/download view
    if a15_stream.present?
      a15_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
      ObjectSpace.undefine_finalizer(a15_file)
      @a15_filepath = a15_file.path
      @a15_filename = "#{@report.ntd_form.organization.short_name}_A15_#{Date.today}.xlsx"
      begin
        a15_file << a15_stream.string
      rescue => ex
        Rails.logger.warn ex
      ensure
        a15_file.close
      end
    end

    if a35_stream.present?
      a35_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
      ObjectSpace.undefine_finalizer(a35_file)
      @a35_filepath = a35_file.path
      @a35_filename = "#{@report.ntd_form.organization.short_name}_A35_#{Date.today}.xlsx"
      begin
        a35_file << a35_stream.string
      rescue => ex
        Rails.logger.warn ex
      ensure
        a35_file.close
      end
    end

    if a20_stream.present?
      a20_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
      ObjectSpace.undefine_finalizer(a20_file)
      @a20_filepath = a20_file.path
      @a20_filename = "#{@report.ntd_form.organization.short_name}_A20_#{Date.today}.xlsx"
      begin
        a20_file << a20_stream.string
      rescue => ex
        Rails.logger.warn ex
      ensure
        a20_file.close
      end
    end

    if a90_stream.present?
      a90_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
      ObjectSpace.undefine_finalizer(a90_file)
      @a90_filepath = a90_file.path
      @a90_filename = "#{@report.ntd_form.organization.short_name}_A90_#{Date.today}.xlsx"
      begin
        a90_file << a90_stream.string
      rescue => ex
        Rails.logger.warn ex
      ensure
        a90_file.close
      end
    end

    if a90_group_stream.present?
      a90_group_file = Tempfile.new ['template', '.tmp'], "#{Rails.root}/tmp"
      ObjectSpace.undefine_finalizer(a90_group_file)
      @a90_group_filepath = a90_group_file.path
      @a90_group_filename = "#{Organization.get_typed_organization(@report.ntd_form.organization).tam_group(@report.ntd_form.fy_year)}_A90_#{Date.today}.xlsx"
      begin
        a90_group_file << a90_group_stream.string
      rescue => ex
        Rails.logger.warn ex
      ensure
        a90_group_file.close
      end
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


    if filename.ends_with?('.zip')
      send_data(data, type: 'application/zip', disposition: 'attachment', filename: filename)
    else
      send_data data, :filename => filename, :type => "application/vnd.ms-excel"
    end
  end

  protected


  private

  def get_form
    # See if it is our project
    @form = NtdForm.find_by(:object_key => params[:ntd_form_id]) unless params[:ntd_form_id].nil?
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @form.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(form_ntd_forms_url(@form_type))
      return
    end
  end

  def get_report
    # See if it is our project
    @report = NtdReport.find_by(:object_key => params[:id]) unless params[:id].nil?
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @report.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(form_ntd_form_url(@form_type, @form))
      return
    end
  end

end
