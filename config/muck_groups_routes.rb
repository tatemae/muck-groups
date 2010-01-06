ActionController::Routing::Routes.draw do |map|

  # groups
  map.resources :groups, :controller => 'muck/groups'

end
