Rails.application.routes.draw do

  resources :funding_sources do
    collection do
        get 'details'
    end
  end

  resources :grants do
    member do
      get 'assets'
    end
    resources :documents
  end

end
