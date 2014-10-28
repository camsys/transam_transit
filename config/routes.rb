Rails.application.routes.draw do
  
  resources :funding_sources do
    collection do
        get 'details'      
    end
  end
  
  resources :grants do
    resources :documents
  end
    
end
