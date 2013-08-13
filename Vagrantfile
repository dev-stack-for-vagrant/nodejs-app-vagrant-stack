# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"Asia/Taipei\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  config.vm.define :wepapp do |wepapp_config|
    # Map dev.pyrocms.mysql to this IP
    #config.vm.network :hostonly, "198.18.0.201"
    wepapp_config.vm.network :forwarded_port, guest: 8080, host: 8080
    # Enable Puppet
    wepapp_config.vm.provision :puppet do |puppet|
      puppet.facter = {
        "fqdn" => "wepapp.dev",
        "hostname" => "wepapp",
        "docroot" => '/vagrant/www/'
      }
      puppet.manifest_file = "default.pp"
      puppet.manifests_path = "misc/recipes/manifests"
    end
  end
end
