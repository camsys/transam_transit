class GrantsController < OrganizationAwareController

  # Include the fiscal year mixin
  include FiscalYear

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Grants", :grants_path

  before_action :set_grant

  INDEX_KEY_LIST_VAR    = "grants_key_list_cache_var"

  def index

    # get range of fiscal years of all grants
    min_fy = Grant.minimum(:fy_year)
    date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{min_fy}"
    start_of_min_fy = Date.strptime(date_str, "%m-%d-%Y")
    @fiscal_years = get_fiscal_years(start_of_min_fy)

     # Start to set up the query
    conditions  = []
    values      = []

    @funding_source_id = params[:funding_source_id]
    unless @funding_source_id.blank?
      @funding_source_id = @funding_source_id.to_i
      conditions << 'funding_source_id = ?'
      values << @funding_source_id
    end

    @fiscal_year = params[:fiscal_year]
    unless @fiscal_year.blank?
      @fiscal_year = @fiscal_year.to_i
      conditions << 'fy_year = ?'
      values << @fiscal_year
    end

    @grants = Grant.where(conditions.join(' AND '), *values).includes(:grant_purchases)

    # cache the set of object keys in case we need them later
    cache_list(@grants, INDEX_KEY_LIST_VAR)

    if @funding_source_id.blank?
      add_breadcrumb "All"
    else
      add_breadcrumb FundingSource.find(@funding_source_id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @grants }
    end

  end

  def summary_info

    respond_to do |format|
      format.js # summary_info.js.haml
      format.json { render :json => @grant }
    end

  end

  # GET /grants/1
  # GET /grants/1.json
  def show

    add_breadcrumb @grant.funding_source, funding_sources_path(:funding_source_id => @grant.funding_source)
    add_breadcrumb @grant.name, grant_path(@grant)


    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@grant, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : grant_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : grant_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @grant }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find_by_object_key(params[:id])
    end

end
