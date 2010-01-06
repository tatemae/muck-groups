require 'aasm'

ActionController::Base.send :helper, MuckGroupsHelper

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::MuckGroup }
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::MuckMembership }
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::MuckMembershipRequest }

I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '..', 'locales', '*.{rb,yml}') ]