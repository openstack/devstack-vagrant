node default {
  $dir = '/home/stack/devstack'

  file {"/etc/hostname":
    ensure => absent
  }

  file {"/etc/udev/rules.d/70-persistent-net.rules":
    ensure => absent
  }

  exec {"clean.sh":
    cwd => $dir,
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.",
    user => 'stack',
    command => "$dir/clean.sh",
    logoutput => "on_failure",
  }
}
