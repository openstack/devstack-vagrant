class user::stack(
  $username = 'stack'
)
{

  notify {'after':
    message => "User params: u => $username, p => $stack_pass, k => $stack_sshkey"
  }


  file {'/etc/sudoers.d/stack':
    owner => "root",
    group => "root",
    mode  => 440,
    source => "puppet:///modules/user/stack_sudoers"
  } ->

  user::create {'stack':
    user => $username,
    pass => $stack_pass,
    key => $stack_sshkey,
    is_admin => true,
  } ->

  file {'/home/stack/.bashrc':
    owner => $username,
    group => $username,
    mode  => 644,
    source => "puppet:///modules/user/stack_bashrc"
  }

}
