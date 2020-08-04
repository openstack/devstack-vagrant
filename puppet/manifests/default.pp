node default {
  include base
  include user::stack
  class {'user::vagrant':
    username => $::vagrant_username,
  }
  include grenade
  include devstack

  Class['base'] -> Class['user::stack'] -> Class['user::vagrant']
  Class['user::stack'] -> Class['grenade']
  Class['user::stack'] -> Class['devstack']
}
