Rails.application.routes.draw do

  resources :rule_sets, :only => [] do
    resources :tam_policies do
      collection do
        get 'search'
        get 'tam_groups'
        get 'tam_metrics'
        get 'get_tam_groups'
        get 'get_tam_group_organizations'
      end

      member do
        get 'copy'
      end

      resources :tam_groups, :except => [:index, :show] do
        member do
          get 'fire_workflow_event'
          get 'distribute'
        end

        resources :tam_performance_metrics, :only => [:update] do
          collection do
            put 'update_all'
          end
        end
      end
    end
  end

  resources :inventory, :only => [], :controller => 'assets' do
    resources :facility_rollup_wizard, controller: 'assets/facility_rollup_wizard'
    collection do
      get 'filter', to: 'assets/asset_filter#filter'
    end
    member do
      get 'mode_collection', to: 'assets/asset_collections#mode_collection'
      get 'service_collection', to: 'assets/asset_collections#service_collection'
    end
  end

  resources :performance_restrictions, :only => [:index]
  get '/segmentable/get_overlapping', to: 'segmentable_aware#get_overlapping'


  resources :asset_fleets do
    collection do
      get 'orphaned_assets'

      get 'new_asset'
      get 'add_asset'
      get 'new_fleet'

      get 'builder'
      get 'runner'
    end

    member do
      delete 'remove_asset'
      get 'render_mileage_table'
    end

  end

  # NTD Forms Controllers
  resources :forms, :only => [] do
    resources :ntd_forms do
      resources :ntd_reports do

        collection do
          get   'download_file'
        end

        member do
          get 'generate'
          get 'comments'
          get 'process_log'
        end

      end

      member do
        get 'fire_workflow_event'
      end

    end

    resources :tam_service_life_reports do
      member do
        get :details
        get :export_data
      end
    end
  end

  resources :ntd_reports, :only => [:show] do
    resources :comments
  end

  resources :transit_query_filters, only: [] do
    collection do
      get 'vehicle_rebuild_types'
    end
  end

end
