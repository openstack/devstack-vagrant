# == Class: user::create
#

define user::create (
  $user = '',
  $pass = '',
  $key = '',
  $key_type = 'rsa',
  $home = "/home/${user}",
  $is_admin = false,
)
{
  if $is_admin == true {
    $extra_groups = ['sudo', 'dialout']
  }
  else {
    $extra_groups = ['dialout']
  }

  group { $extra_groups:
    ensure => present,
  } ->

  group { $user:
    ensure => present,
  } ->

  user { $user:
    ensure => present,
    gid => $user,
    password => $pass,
    home => $home,
    groups => $extra_groups,
    shell => '/bin/bash'
  } ->

  file { $home:
    ensure => directory,
    owner => $user,
    group => $user,
    mode => '0755',
  } ->

  file { "${home}/bin":
    ensure => directory,
    owner => $user,
    group => $user,
    mode => '0755',
  } ->

  file { "${home}/.ssh":
    ensure => directory,
    owner => $user,
    group => $user,
    mode => '0700',
  } ->

  ssh_authorized_key { $user:
    ensure => present,
    key => $key,
    user => $user,
    type => $key_type,
  }

}
