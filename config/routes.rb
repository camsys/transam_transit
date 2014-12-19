Rails.application.routes.draw do

  resources :funding_sources do
    collection do
        get 'details'
    end
  end

  resources :grants do
    member do
      get 'summary_info'
    end
    resources :comments
    resources :documents
  end

end
