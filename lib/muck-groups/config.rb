module MuckGroups
  
  def self.configuration
    # In case the user doesn't setup a configure block we can always return default settings:
    @configuration ||= Configuration.new
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :enable_solr
    attr_accessor :enable_sunspot
    attr_accessor :enable_group_activities
    
    def initialize
      self.enable_solr = true
      self.enable_sunspot = false
      self.enable_group_activities = true
    end
    
  end
end