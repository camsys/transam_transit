class Assets::AssetCollectionsController < AssetsController
  before_action :get_asset
  
  def mode_collection
    render_collection(FtaModeType, "_ids")
  end
  def service_collection
    render_collection(FtaServiceType, "_id")
  end

  protected

  def render_collection(klass, secondary_suffix)
    klass_ = klass.to_s.underscore
    is_secondary = (params[:type] == 'secondary')
    collection = klass
                 .where.not(id: is_secondary ?
                              @asset.send("primary_#{klass_}_id") :
                              @asset.send("secondary_#{klass_}#{secondary_suffix}"))
                 .pluck(:id, :name)
                 .map{|pair| {value: "#{pair[0]}", text: "#{pair[1].gsub("'"){"\\'"}}"}}
    collection.unshift({value: '', text: ''}) if is_secondary
    respond_to do |format|
      format.json { render json: collection }
    end
  end
end