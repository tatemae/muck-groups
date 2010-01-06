RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

# Load a global constant so the initializers can use them
require 'ostruct'
require 'yaml'
::GlobalConfig = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/global_config.yml")[RAILS_ENV])

class TestGemLocator < Rails::Plugin::Locator
  def plugins
    Rails::Plugin.new(File.join(File.dirname(__FILE__), *%w(.. .. ..)))
  end 
end

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.gem "authlogic"
  config.gem "searchlogic"
  config.gem "will_paginate"
  config.gem "bcrypt-ruby", :lib => "bcrypt"
  config.gem "paperclip"
  config.gem "acts-as-taggable-on"
  config.gem "awesome_nested_set"
  config.gem "sanitize"
  config.gem "geokit"
  config.gem "aasm"
  config.gem 'muck-engine', :lib => 'muck_engine'
  config.gem 'muck-users', :lib => 'muck_users'
  config.gem 'muck-profiles', :lib => 'muck_profiles'
  config.gem "muck-solr", :lib => 'acts_as_solr'
  config.gem "muck-comments", :lib => 'muck_comments'
  config.plugin_locators << TestGemLocator
end