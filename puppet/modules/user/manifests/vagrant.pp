# == Class: user::vagrant
#

class user::vagrant(
  $username = 'vagrant'
)
{
  file {'/home/vagrant/.bashrc':
    owner => $username,
    group => $username,
    mode => '0644',
    source => 'puppet:///modules/user/stack_bashrc',
  }

  file {'/home/vagrant/devstack':
    owner => $username,
    group => $username,
    mode => '0644',
    ensure => 'link',
    target => '/home/stack/devstack',
  }

  file {'/home/vagrant/grenade':
    owner => $username,
    group => $username,
    mode => '0644',
    ensure => 'link',
    target => '/home/stack/grenade',
  }

}
