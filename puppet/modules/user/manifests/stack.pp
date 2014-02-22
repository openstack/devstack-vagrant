class user::stack() {

  file {'/etc/sudoers.d/stack':
    owner => "root",
    group => "root",
    mode  => 440,
    source => "puppet:///modules/user/stack_sudoers"
  } ->

  user::create {'stack':
    user => 'stack',
    pass => $stack_pass,
    key => $stack_sshkey,
    is_admin => true,
  } ->

  file {'/home/stack/.bashrc':
    owner => "stack",
    group => "stack",
    mode  => 644,
    source => "puppet:///modules/user/stack_bashrc"
  }

}
