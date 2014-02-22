class devstack(
  $dir = '/home/stack/devstack'
)
{
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
    owner => "stack",
    group => "stack",
    mode  => 755,
    source => "puppet:///modules/devstack/local.sh",
    require => vcsrepo[ $dir ]
  }

  file { "$dir/local.conf":
    owner => "stack",
    group => "stack",
    mode  => 644,
    source => "puppet:///modules/devstack/$localrc",
    require => [vcsrepo[ $dir ], file["$dir/local.sh"]]
  }

  exec {"stack.sh":
    require => [vcsrepo[ $dir ], file["$dir/local.conf"]],
    cwd => $dir,
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.",
    user => 'stack',
    command => "$dir/stack.sh",
    logoutput => true,
    timeout => 1200
  }
}
