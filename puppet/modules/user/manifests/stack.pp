# == Class: user::stack
#

class user::stack(
  $username = 'stack'
)
{

  notify { 'after':
    message => "User params: u => $username, p => $stack_password, k => $stack_sshkey, t => $stack_sshkey_type"
  }


  file { '/etc/sudoers.d/stack':
    owner => 'root',
    group => 'root',
    mode => '0440',
    source => 'puppet:///modules/user/stack_sudoers',
  } ->

  user::create { 'stack':
    user => $username,
    pass => $stack_password,
    key => $stack_sshkey,
    key_type => $stack_sshkey_type,
    is_admin => true,
  } ->

  file {'/home/stack/.bashrc':
    owner => $username,
    group => $username,
    mode => '0644',
    source => 'puppet:///modules/user/stack_bashrc',
  }

}
