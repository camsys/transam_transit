class PerformanceRestrictionsController < OrganizationAwareController

  before_action :reformat_date_fields, only: [:index]

  def index
    asset_event_type = AssetEventType.find_by(class_name: 'PerformanceRestrictionUpdateEvent')

    unless asset_event_type.nil?
      asset_event_klass = asset_event_type.class_name.constantize

      if params[:order].blank?
        @restrictions = asset_event_klass.all
      else
        @restrictions = asset_event_klass.unscoped.order(params[:order])
      end

      if asset_event_klass.count > 0
        asset_klass = asset_event_klass.first.send(Rails.application.config.asset_base_class_name.underscore).class

        asset_joins = [Rails.application.config.asset_base_class_name.underscore]

        while asset_klass.try(:acting_as_name)
          asset_joins << asset_klass.acting_as_name
          asset_klass = asset_klass.acting_as_name.classify.constantize
        end


        idx = asset_joins.length-2
        join_relations = Hash.new
        join_relations[asset_joins[idx]] = asset_joins[idx+1]
        idx -= 1
        while idx >= 0
          tmp = Hash.new
          tmp[asset_joins[idx]] = join_relations
          join_relations = tmp
          idx -= 1
        end

        @restrictions = @restrictions.includes(join_relations).where(transam_asset: asset_event_klass.first.send(Rails.application.config.asset_base_class_name.underscore).class.where(organization_id: @organization_list))
      end

      if params[:start_datetime].present? || params[:end_datetime].present? # ignores scope if date range given
        @restrictions = @restrictions.active_in_range(params[:start_datetime], params[:end_datetime])
      else
        unless params[:scope].blank?
          if asset_event_klass.respond_to? params[:scope]
            @restrictions = @restrictions.send(params[:scope])
          end
        end
      end


      respond_to do |format|
        format.html
        format.js {
          render partial: "performance_restrictions/index_table", locals: {results: @restrictions }
        }
        # format.xlsx do
        #   response.headers['Content-Disposition'] = "attachment; filename=Performance Restrictions Table Export.xlsx"
        # end
      end

    end
  end

  private

  def reformat_date_fields
    params[:start_datetime] = reformat_date(params[:start_datetime]) unless params[:start_datetime].blank?
    params[:end_datetime] = reformat_date(params[:end_datetime]) unless params[:end_datetime].blank?
  end

  def reformat_date(date_str)
    form_date = Date.strptime(date_str, '%m/%d/%Y')
    return form_date.strftime('%Y-%m-%d')
  end

end
