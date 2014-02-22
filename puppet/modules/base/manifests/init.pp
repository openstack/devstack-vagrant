class base {
  $editors = ["joe", "vim"]
  $vcs = ["git"]
  package {$editors:
    ensure => latest
  }
  package {$vcs:
    ensure => latest
  }
}
