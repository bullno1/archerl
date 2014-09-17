# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "archlinux64"
  config.vm.box_url = "http://www.eduardoheredia.com.br/rep/vagrant/archlinux64.box"

  config.vm.synced_folder ".", "/vagrant"
  config.vm.provision "shell", inline: "pacman --noconfirm -S arch-install-scripts"

  # Cache packages
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
