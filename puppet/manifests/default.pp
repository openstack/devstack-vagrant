node default {
  include base
  include user::stack
  include user::vagrant
  include grenade
  include devstack
}
