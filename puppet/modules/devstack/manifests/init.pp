class devstack(
  $dir = '/home/stack/devstack'
)
{
  $user = $user::stack::username

  if $devstack_git {
    $source = $devstack_git
  } else {
    $source = 'https://github.com/openstack-dev/devstack'
  }

  if $devstack_branch {
    $branch = $devstack_branch
  } else {
    $branch = 'master'
  }

  exec { "devstack_clone":
    require => File["/usr/local/bin/git_clone.sh"],
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.",
    environment => "HOME=/home/$user",
    user => 'stack',
    group => 'stack',
    command => "/usr/local/bin/git_clone.sh ${source} ${branch} ${dir}",
    logoutput => true,
    timeout => 1200
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
    require => Exec[ "devstack_clone" ]
  }

  file { "$dir/local.conf":
    owner => $user,
    group => $user,
    mode  => 644,
    source => "puppet:///modules/devstack/$localrc",
    require => File["$dir/local.sh"]
  }

  exec {"stack.sh":
    require => [ File["$dir/local.conf"], File["$dir/local.sh"] ],
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
