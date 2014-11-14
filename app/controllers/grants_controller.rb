class GrantsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Grants", :grants_path

  before_action :set_grant

  INDEX_KEY_LIST_VAR    = "grants_key_list_cache_var"

  def index
    
     # Start to set up the query
    conditions  = []
    values      = []
        
    @grants = Grant.where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@grants, INDEX_KEY_LIST_VAR)
              
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @grants }
    end

  end
  
  # GET /grants/1
  # GET /grants/1.json
  def show
    
    add_breadcrumb @grant.funding_source, funding_sources_path(:funding_source_type_id => @grant.funding_source)
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
