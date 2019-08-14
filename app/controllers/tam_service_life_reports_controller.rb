class TamServiceLifeReportsController < OrganizationAwareController

  # Lock down the controller
  #authorize_resource only: [:index, :show]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Reports", :reports_path

  before_action :handle_show, except: :index

  SESSION_VIEW_TYPE_VAR = 'reports_subnav_view_type'

  def index
    fta_asset_category = FtaAssetCategory.find_by(id: params[:fta_asset_category_id])

    if fta_asset_category
      class_name = case fta_asset_category.name
        when 'Revenue Vehicles'
          'RevenueVehicle'
        when 'Equipment'
          'ServiceVehicle'
        when 'Facilities'
          'Facility'
        when 'Infrastructure'
          'Track'
      end

      redirect_to tam_service_life_report_path(class_name, request.parameters.except(:controller, :action, :fta_asset_category_id))

    end
  end

  def show
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
        render template: "reports/show.csv.haml"
      end
    end
  end

  def details
    @data = @report_instance.class.get_detail_data(@organization_list, params)
    @key = params[:key]
    @details_view = params[:view]
    render 'reports/report_details'
  end

  def export_data
    @data = @report_instance.class.get_underlying_data(@organization_list, params)

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment;filename=#{@sanitized_report_name}.csv"
        render template: "reports/show.csv.haml"
      end
    end

  end

  def report_pdf_template(report_name)
    render_to_string(pdf: "#{report_name}", template: "reports/show", orientation: 'Landscape',
                     header: { right: '[page] of [topage]' })
  end


  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def handle_show

    @report_instance = "#{params[:id]}TamPolicyServiceLifeReport".classify.constantize.new

    if @report_instance
      # get the report data
      @data = @report_instance.get_data(@organization_list, params)

      categories = FtaAssetCategory.pluck(:name, :id).map{|x|
        if x[0] == 'Equipment'
          ['Equipment - Service Vehicles', x[1]]
        elsif x[0] == 'Infrastructure'
          ['Infrastructure - Track', x[1]]
        else
          x
        end
      }
      @actions = [
          {
              type: :select,
              where: :has_organization,
              values: [['Consolidated View', 0], ['Single Organization', 1]],
              label: 'View'
          },


          {
              type: :select,
              where: :fta_asset_category_id,
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