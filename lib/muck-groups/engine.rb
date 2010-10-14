require 'muck-groups'
require 'rails'

module MuckGroups
  class Engine < ::Rails::Engine
    
    def muck_name
      'muck-groups'
    end
    
    initializer 'muck-groups.helpers' do
      ActiveSupport.on_load(:action_view) do
        include MuckGroupsHelper
      end
    end
        
  end
end
