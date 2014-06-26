# == Class: base
#

class base {

  $vim = $::operatingsystem ? {
    /RedHat|Fedora|Centos/ => 'vim-enhanced',
    default => 'vim',
  }

  $editors = ['joe', $vim]
  $vcs = ['git']

  package { $editors:
    ensure => latest
  }

  package { $vcs:
    ensure => latest
  }

  file { '/usr/local/bin/git_clone.sh':
    owner => 'root',
    group => 'root',
    mode => '0755',
    source => 'puppet:///modules/base/git_clone.sh',
    require => Package[$vcs],
  }

}
