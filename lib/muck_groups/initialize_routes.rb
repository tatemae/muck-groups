class ActionController::Routing::RouteSet
  def load_routes_with_muck_groups!
    muck_groups_routes = File.join(File.dirname(__FILE__), *%w[.. .. config muck_groups_routes.rb])
    add_configuration_file(muck_groups_routes) unless configuration_files.include? muck_groups_routes
    load_routes_without_muck_groups!
  end
  alias_method_chain :load_routes!, :muck_groups
end