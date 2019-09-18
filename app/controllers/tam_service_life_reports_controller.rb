class TamServiceLifeReportsController < FormAwareController

  # Lock down the controller
  #authorize_resource only: [:index, :show]

  add_breadcrumb "Home", :root_path

  before_action :handle_show, except: :index

  def index
    if params[:id]
      redirect_to form_tam_service_life_report_path(@form_type, params[:id], request.parameters.except(:controller, :action, :id))
    else
      redirect_to form_tam_service_life_report_path(@form_type, 'RevenueVehicle')
    end
  end

  def show
    add_breadcrumb 'TAM Service Life Report', form_tam_service_life_report_path(@form_type,params[:id])

    respond_to do |format|
      format.html
      format.xls do
        response.headers['Content-Disposition'] = "attachment; filename=#{@sanitized_report_name}.xls"
      end
      format.pdf do
        send_data report_pdf_template(@sanitized_report_name), type: 'application/pdf', disposition: 'inline'
      end
      format.csv do
        headers['Content-Disposition'] = "attachment;filename=#{@sanitized_report_name}.csv"
        render template: "tam_service_life_reports/show.csv.haml"
      end
    end
  end

  def export_data

    @data = @report_instance.get_underlying_data(@organization_list, params)

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment;filename=#{@sanitized_report_name}.csv"
        render template: "tam_service_life_reports/show.csv.haml"
      end
    end

  end

  def report_pdf_template(report_name)
    render_to_string(pdf: "#{report_name}", template: "tam_service_life_reports/show", orientation: 'Landscape',
                     header: { right: '[page] of [topage]' })
  end


  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def handle_show

    @report_instance = "#{params[:id]}TamServiceLifeReport".classify.constantize.new

    if @report_instance
      # get the report data
      @data = @report_instance.get_data(@organization_list, params)

      categories = FtaAssetCategory.pluck(:name).map{|x|
        if x == 'Equipment'
          ['Equipment - Service Vehicles', 'ServiceVehicle']
        elsif x == 'Infrastructure'
          ['Infrastructure - Track', 'Track']
        else
          [x, x.gsub(' ','').classify]
        end
      }


      org_views = [['Consolidated View', 0], ['Single Organization', 1]]
      @actions = [
          {
              type: :select,
              where: :has_organization,
              values: @organization_list.count > 1 ? org_views : org_views[-1..-1],
              label: 'View'
          },


          {
              type: :select,
              where: :id,
              values: categories,
              label: 'Asset Category'
          }

      ]

      @sanitized_report_name = @report_instance.class.to_s.underscore

      # String return value indicates an error message.
      if @data.is_a? String
        notify_user(:alert, @data)
        redirect_to root_path
      end
    end
  end



end