Rails.application.routes.draw do

  # groups
  resources :groups, :controller => 'muck/groups'
  resources :memberships, :controller => 'muck/memberships'

end
