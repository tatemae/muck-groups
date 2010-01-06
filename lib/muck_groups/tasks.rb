require 'rake'
require 'rake/tasklib'
require 'fileutils'

module MuckGroups
  class Tasks < ::Rake::TaskLib
    def initialize
      define
    end
  
    private
    def define
      
      namespace :muck do
        namespace :groups do
          desc "Sync required files from groups."
          task :sync do
            path = File.join(File.dirname(__FILE__), *%w[.. ..])
            system "rsync -ruv #{path}/db ."
          end
        end
      end

    end
  end
end
MuckGroups::Tasks.new