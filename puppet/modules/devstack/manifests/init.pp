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

  file { "/usr/local/bin/git_clone.sh":
    owner => "root",
    group => "root",
    mode  => 755,
    source => "puppet:///modules/devstack/git_clone.sh",
  }

  exec { "git_clone.sh":
    require => File["/usr/local/bin/git_clone.sh"],
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.",
    environment => "HOME=/home/$user",
    user => 'stack',
    group => 'stack',
    command => "/usr/local/bin/git_clone.sh $devstack_git $devstack_branch $dir",
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
    require => Exec[ "git_clone.sh" ]
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
