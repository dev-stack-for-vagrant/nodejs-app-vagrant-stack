$user = 'vagrant'

$user_bash_prefix = "sudo -u ${user} -H bash -l -c"
$root_bash_prefix = 'sudo -H bash -l -c'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin', '/usr/local/bin']
}

# --- Pre-update Stage --------------------------------------------------------
stage { 'pre_update':
  before => Stage['main']
}

class apt_get_update {

  class { 'apt': }
  apt::ppa { 'ppa:chris-lea/node.js': }

  exec { '/usr/bin/apt-get -y update':
    user => 'root'
  }
}

class { 'apt_get_update':
  stage => ['pre_update']
}

# --- Pre-install Packages ----------------------------------------------------
stage { 'pre_install_packages':
  before => Stage['main'],
  require => Stage['pre_update']
}

class pre_install_packages {
  package { [ 'vim', 'curl', 'zsh', 'git', 'wget', 'python-dev', 'python-pip', 'nodejs' ]:
      ensure => installed
  }
}

class { 'pre_install_packages':
  stage => ['pre_install_packages']
}

# --- Pre-setting --------------------------------------------------------------
class pre_settting {
  # add zsh
  exec { 'user_install_zsh':
    command =>
      "${user_bash_prefix} 'wget -O - https://raw.github.com/JustinTW/rc/master/auto-install.sh | sh'"
  }
  exec { 'root_install_zsh':
    command =>
      "${root_bash_prefix} 'wget -O - https://raw.github.com/JustinTW/rc/master/auto-install.sh | sh'"
  }

  exec { 'change_shell':
    command =>
      "${root_bash_prefix} 'chsh -s /usr/bin/zsh root && chsh -s /usr/bin/zsh vagrant'",
  }
}

class { 'pre_settting':
  stage => ['pre_install_packages'],
  require => Class['pre_install_packages']
}

# --- Post-install Packages----------------------------------------------------
stage { 'post_install_packages':
  before => Stage['main'],
  require => Stage['pre_install_packages']
}

class post_install_packages {
  package { ['libevent-dev', 'libldap2-dev', 'libsasl2-dev', 'mongodb']:
    ensure => 'installed'
  }

  package { 'virtualenvwrapper':
    ensure   => present,
    provider => 'pip',
    require  => Package['python-pip']
  }

  package { 'grunt-cli':
    ensure   => present,
    provider => 'npm',
    require  => Package['nodejs']
  }
}

class { 'post_install_packages':
  stage => ['post_install_packages']
}


# --- Post-settings -----------------------------------------------------------
class post_settings {
  # exec { 'setting_up_virtualenv':
  #   command =>
  #     "${root_bash_prefix} 'cd /vagrant/src && \
  #     mkvirtualenv app'",
  #   require => Package['virtualenvwrapper']
  # }
}

class { 'post_settings':
  stage => ['post_install_packages'],
  require => Class['post_install_packages']
}

# --- Prepare wrokspace --------------------------------------------------------------
class workspace_settings{

  file { 'web_folder':
    path => '/var/www/',
    ensure => 'directory'
  }

  exec { 'link_webapp':
    command =>
      "${root_bash_prefix} 'rm /var/www/webapp -rf && \
      ln -s -f /vagrant /var/www/webapp'",
    require => File['web_folder']
  }

  # exec { 'fixture_webapp':
  #   command =>
  #     "${root_bash_prefix} 'cd /var/www/webapp && \
  #     python /var/www/webapp/fixtures.py &'",
  #   require => Exec['link_webapp']
  # }

  # exec { 'run_webapp':
  #   command =>
  #     "${root_bash_prefix} 'cd /var/www/webapp && \
  #     # workon webapp && \
  #     python /var/www/webapp/server.py &'",
  #   require => Exec['link_webapp']
  # }
}

class { 'workspace_settings': }
