node default {
  include base
  include user::stack
  class {'user::vagrant':
    username => $::vagrant_username,
  }
  include grenade
  include devstack
}
