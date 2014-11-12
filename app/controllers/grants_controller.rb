class GrantsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  before_action :set_grant

  def assets
    add_breadcrumb @grant.grant_number, assets_grant_path(@grant)

    @assets = @grant.assets
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find_by_object_key(params[:id])
    end

end
