require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--color", "-c", "-f progress", "-r test/spec/spec_helper.rb"]
  t.pattern = 'test/spec/**/*_spec.rb'  
end
task :spec => :check_dependencies

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "muck-groups"
    
    gem.summary = %Q{Groups for muck}
    gem.description = %Q{Groups are an assembly of people}
    gem.email = "justin@tatemae.com"
    gem.homepage = "http://github.com/tatemae/muck-groups"
    gem.authors = ["Justin Ball", "Joel Duffin"]
    gem.add_development_dependency "shoulda"
    gem.add_dependency "sanitize"
    gem.add_dependency "aasm"
    gem.add_dependency "paperclip"
    gem.add_dependency "geokit"
    gem.add_dependency "friendly_id"
    gem.add_dependency "muck-engine"
    gem.add_dependency "muck-users"
    gem.add_dependency "muck-profiles"
    gem.add_dependency "muck-comments"
    gem.add_dependency "muck-solr"
    gem.files.exclude 'test/**'
    gem.test_files.exclude 'test/**'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/test/**/*_spec.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "muck-groups #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
