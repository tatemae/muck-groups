require 'fileutils'

namespace :muck do
  namespace :sync do
    desc "Sync required files from groups."
    task :groups do
      path = File.join(File.dirname(__FILE__), *%w[.. ..])
      system "rsync -ruv #{path}/db ."
    end
  end
end
