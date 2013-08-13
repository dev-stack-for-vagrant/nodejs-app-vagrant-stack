$user = 'vagrant'

$user_bash_prefix = "sudo -u ${user} -H bash -l -c"
$root_bash_prefix = 'sudo -H bash -l -c'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall Stage --------------------------------------------------------
stage { 'preinstall':
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
  stage => preinstall
}

# --- Install Basic Packages --------------------------------------------------------
stage { 'install_basic_packages':
  before => Stage['main'],
  require => Stage['preinstall']
}

class install_basic_packages {
  package { ['vim', 'curl', 'zsh', 'git', 'wget', 'python-dev', 'python-pip', 'nodejs']:
      ensure => installed
  }

  package { 'grunt-cli':
    ensure   => present,
    provider => 'npm',
    require  => Package['nodejs']
  }

  exec { 'install_pip_warper':
    command =>
    "${root_bash_prefix} 'pip install virtualenvwrapper'",
    require => Package["python-pip"]
  }
}

class { 'install_basic_packages':
  stage => ['install_basic_packages']
}

# --- Setting up Env ----------------------------------------------------------
class setup_env {
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

class { 'setup_env':
  stage => ['install_basic_packages'],
  require => Class['install_basic_packages']
}

# --- Install apt-require --------------------------------------------------------
stage { 'install_apt_require':
  before => Stage['main'],
  require => Stage['install_basic_packages']
}

class install_apt_require {
  # package { ['libevent-dev', 'libldap2-dev', 'libsasl2-dev', 'mongodb']:
  #   ensure => 'installed'
  # }
}

class { 'install_apt_require':
  stage => ['install_apt_require']
}


# --- Install pip-require --------------------------------------------------------
stage { 'install_pip_require':
  before => Stage['main'],
  require => Stage['install_apt_require']
}

class install_pip_require {

  exec { 'install_pip_require':
    command =>
      "${root_bash_prefix} 'cd /vagrant && \
      # source /usr/local/bin/virtualenvwrapper.sh  && \
      # mkvirtualenv app -r /vagrant/pip.require&& \
      # workon app && \
      pip install -r /vagrant/pip.require'"
  }
}

class { 'install_pip_require':
  stage => ['install_pip_require']
}

# --- Prepare wrokspace --------------------------------------------------------------
class prepare_workspace{

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

class { 'prepare_workspace': }
