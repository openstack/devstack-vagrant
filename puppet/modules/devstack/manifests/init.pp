class devstack(
  $dir = '/home/stack/devstack'
)
{
  $user = $user::stack::username
  vcsrepo { $dir:
    ensure => latest,
    provider => git,
    source => 'http://github.com/openstack-dev/devstack',
    require => Class["user::stack"],
    user => 'stack',
    revision => 'master'
  }

  if $is_compute == 'true' {
    $localrc = 'compute.conf'
  } else {
    $localrc = 'manager.conf'
  }

  file { "$dir/local.sh":
    owner => $user,
    group => $user,
    mode  => 755,
    source => "puppet:///modules/devstack/local.sh",
    require => vcsrepo[ $dir ]
  }

  file { "$dir/local.conf":
    owner => $user,
    group => $user,
    mode  => 644,
    source => "puppet:///modules/devstack/$localrc",
    require => [vcsrepo[ $dir ], file["$dir/local.sh"]]
  }

  exec {"stack.sh":
    require => [vcsrepo[ $dir ], file["$dir/local.conf"]],
    cwd => $dir,
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.",
    environment => "HOME=/home/$user",
    user => 'stack',
    group => 'stack',
    command => "$dir/stack.sh",
    logoutput => true,
    timeout => 1200
  }
}
