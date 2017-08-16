Rails.application.routes.draw do

  resources :inventory, :only => [], :controller => 'assets' do
    resources :facility_rollup_wizard, controller: 'assets/facility_rollup_wizard'
  end

end
