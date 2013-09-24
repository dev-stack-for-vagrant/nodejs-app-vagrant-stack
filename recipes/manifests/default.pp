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
  package { [ 'vim', 'curl', 'zsh', 'git', 'wget', 'nodejs' ]:
      ensure => installed
  }

  class { 'python':
    version => 'system',
    dev => true,
    virtualenv => true,
    gunicorn => false
  }
}

class { 'pre_install_packages':
  stage => ['pre_install_packages']
}


# --- Pre-settings --------------------------------------------------------------
class pre_setttings {
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

  exec { 'root_add_ssh_folder':
    command =>
      "${root_bash_prefix} 'mkdir -p /root/.ssh'"
  }
}

class { 'pre_setttings':
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

  python::pip { 'virtualenvwrapper': }

  package { ['grunt-cli', 'coffee-script', 'mocha', 'docco']:
    ensure => present,
    provider => 'npm',
    require => Package['nodejs']
  }
}

class { 'post_install_packages':
  stage => ['post_install_packages']
}


# --- Post-settings -----------------------------------------------------------
class post_settings {
  file { 'web_folder':
    path => '/var/www/',
    ensure => 'directory'
  }

  exec { 'link_webapp':
    command =>
      "${root_bash_prefix} 'rm /var/www/app -rf && \
      ln -s -f /vagrant /var/www/app'",
    require => File['web_folder']
  }
}

class { 'post_settings':
  stage => ['post_install_packages'],
  require => Class['post_install_packages']
}

