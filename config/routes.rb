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
  end

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
    end

  end

  # NTD Forms Controllers
  resources :forms, :only => [] do
    resources :ntd_forms do

      # Build controller for form wizard
      resources :steps, controller: 'ntd_forms/steps'

      collection do
        get   'download_file'
      end

      member do
        get 'fire_workflow_event'
        get 'generate'
      end

      resources :comments

    end
  end

end
