# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"Asia/Taipei\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  config.vm.define :nodeapp do |nodeapp_config|
    # Map dev.pyrocms.mysql to this IP
    #config.vm.network :hostonly, "198.18.0.201"
    nodeapp_config.vm.network :forwarded_port, guest: 3000, host: 3300
    # Enable Puppet
    nodeapp_config.vm.provision :puppet do |puppet|
      puppet.facter = {
        "fqdn" => "nodeapp.dev",
        "hostname" => "nodeapp",
        "docroot" => '/vagrant/www/'
      }
      puppet.manifest_file  = "default.pp"
      puppet.manifests_path = "recipes/manifests"
      puppet.module_path    = 'recipes/modules'
    end
  end
end
