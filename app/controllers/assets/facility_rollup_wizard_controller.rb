class Assets::FacilityRollupWizardController < AssetAwareController

  include Wicked::Wizard

  steps :choose_components, :new_component_form, :next_component

  def show

    case step
      when :choose_components

        type_proxies = []
        AssetType.where(class_name: 'Component').each do |asset_type|
          asset_type.asset_subtypes.where.not('name LIKE ?', "%-%").each_with_index do |asset_subtype, idx|
            type_proxies << FacilityRollupAssetTypeProxy.new(asset_type_id: asset_subtype.asset_type_id, asset_subtype_id: asset_subtype.id, quantity: 0, column: idx == 0 ? 1 : 2)
            asset_type.asset_subtypes.where('name LIKE ?', "%-%").where('name LIKE ?', "%#{asset_subtype.name}%").each do |asset_subtype|
              type_proxies << FacilityRollupAssetTypeProxy.new(asset_type_id: asset_subtype.asset_type_id, asset_subtype_id: asset_subtype.id, quantity: 0, column: 3)
            end
          end
        end

        @facility_rollup_proxy = FacilityRollupProxy.new
        @facility_rollup_proxy.facility_rollup_asset_type_proxies = type_proxies
        # load form for choosing components

      when :new_component_form

        if Asset.where(asset_tag: @asset.object_key).count == 0
          jump_to Wicked::FINISH_STEP
        else
          jump_to :next_component
        end

      when :next_component

        @component = Asset.where(asset_tag: @asset.object_key).first
        # loads master record form for asset

    end

    @has_prev_step = previous_step

    render_wizard

  end

  def update
    case step
      when :choose_components
        @facility_rollup_proxy = FacilityRollupProxy.new(form_params)
        @facility_rollup_proxy.facility_rollup_asset_type_proxies.each do |asset_proxy|
          if asset_proxy.quantity.to_i > 0
            type = AssetType.find(asset_proxy.asset_type_id)
            all_subtype = type.asset_subtypes.first
            parent = asset_proxy.asset_subtype_id.to_i == all_subtype.id ? @asset : @asset.dependents.find_by(asset_subtype_id: all_subtype.id)

            (asset_proxy.quantity.to_i).times do
              a = type.class_name.constantize.new(organization_id: @asset.organization_id, asset_type_id: type.id, asset_subtype_id: asset_proxy.asset_subtype_id, parent_id: parent.id)
              a.generate_object_key(:object_key)
              a.asset_tag = @asset.object_key
              a.save(validate: false)
            end
          end
        end
      when :new_component_form
        # does nothing never comes here - always redirects on the #show
      when :next_component
        a = Asset.find_by(object_key: params[:asset][:object_key])
        @component = Asset.get_typed_asset(a)
        @component.creator = current_user
        if @component.update!(asset_params)
          jump_to :new_component_form
        end
    end

    render_wizard @asset
  end

  private

  def form_params
    params.require(:facility_rollup_proxy).permit(FacilityRollupProxy.allowable_params)
  end

  def asset_params
    params.require(:asset).permit(asset_allowable_params)
  end

  def finish_wizard_path
    get_asset
    return inventory_path(@asset)
  end
end
