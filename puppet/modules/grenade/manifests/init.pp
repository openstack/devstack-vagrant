# == Class: grenade
#

class grenade(
  $dir = '/home/stack/grenade'
)
{
  $user = $user::stack::username

  if $grenade_git {
    $source = $grenade_git
  } else {
    $source = 'https://github.com/openstack-dev/grenade'
  }

  if $grenade_branch {
    $branch = $grenade_branch
  } else {
    $branch = 'master'
  }

  exec { 'grenade_clone':
    require => File['/usr/local/bin/git_clone.sh'],
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.',
    environment => "HOME=/home/$user",
    user => 'stack',
    group => 'stack',
    command => "/usr/local/bin/git_clone.sh ${source} ${branch} ${dir}",
    logoutput => true,
    timeout => 1200,
  }

  # file { "$dir/localrc":
  #   owner => $user,
  #   group => $user,
  #   mode  => 644,
  #   source => "puppet:///modules/grenade/localrc",
  #   require => File["$dir/local.sh"]
  # }

  exec { 'grenade.sh':
    require => Exec['grenade_clone'],
    cwd => $dir,
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.',
    environment => "HOME=/home/$user",
    user => 'stack',
    group => 'stack',
    command => "$dir/grenade.sh",
    logoutput => true,
    timeout => 1200
  }
}
