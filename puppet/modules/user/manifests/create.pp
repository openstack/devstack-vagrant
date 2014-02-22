define user::create (
  $user = "",
  $pass = "",
  $key = "",
  $key_type = "rsa",
  $home = "/home/${user}",
  $is_admin = false
)
{
  if $is_admin == true {
    $extra_groups = ['sudo', 'dialout']
  }
  else {
    $extra_groups = ['dialout']
  }

  group {$user:
    ensure => present,
  } ->

  user {$user:
    gid => $user,
    password => $pass,
    home => $home,
    groups => $extra_groups,
    ensure => present,
    shell => "/bin/bash"
  } ->

  file { $home:
    owner => $user,
    group => $user,
    mode => 755,
    ensure => directory,
  } ->

  file { "${home}/bin":
    owner => $user,
    group => $user,
    mode => 755,
    ensure => directory,
  } ->

  file { "${home}/.ssh":
    owner => $user,
    group => $user,
    mode => 700,
    ensure => directory,
  } ->

  ssh_authorized_key { $user:
    key => $key,
    user => $user,
    type => $key_type,
    ensure => present
  }

}
