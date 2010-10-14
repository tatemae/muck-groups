RailsTest::Application.routes.draw do
  root :to => "default#index"
  
  resources :profiles
  resources :users do
    resource :profile
  end
  
  match ':controller(/:action(/:id(.:format)))'
end
