node default {
  include base
  include user::stack
  if $setup_mode == "grenade" {
    include grenade
  }
  if $setup_mode == "devstack" {
    include devstack
  }
}
