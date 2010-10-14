Rails.application.routes.draw do

  # groups
  resources :groups, :controller => 'muck/groups'

end
