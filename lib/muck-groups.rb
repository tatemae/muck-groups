require 'aasm'

require 'muck-groups/config'
require 'muck-groups/share/group_methods'
require 'muck-groups/mailers/groups_mailer'
require 'muck-groups/models/group'
require 'muck-groups/models/membership'
require 'muck-groups/models/membership_request'
require 'muck-groups/engine'

module MuckGroups
  DELETED = -1
  INVISIBLE = 0
  PRIVATE = 1
  PUBLIC = 2
end