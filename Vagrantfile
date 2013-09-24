# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.define "cdvm" do |cdvm|
    cdvm.vm.hostname = "cdvm"
    
    cdvm.vm.network "private_network", ip: "192.168.56.100"
    
    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    #
    cdvm.vm.provider :virtualbox do |vb|
      # Don't boot with headless mode
      vb.gui = true

      # Name in VirtualBox Gui
      vb.name = "CD Workshop cdvm"
 
      # Use VBoxManage to customize the VM:
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--nic1", "nat"]
      vb.customize ["modifyvm", :id, "--nic2", "hostonly"] 
    end
    cdvm.vm.provision "shell" do |s|
      s.path = "./vms/install-vms.sh"
      s.args = "cdvm"
    end
  end

  config.vm.define "testvm" do |testvm|
    testvm.vm.hostname = "testvm"
  
    testvm.vm.network "private_network", ip: "192.168.56.101"

    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    #
    testvm.vm.provider :virtualbox do |vb|
      # Don't boot with headless mode
      vb.gui = true

      # Name in VirtualBox Gui
      vb.name = "CD Workshop testvm"
 
      # Use VBoxManage to customize the VM:
      vb.customize ["modifyvm", :id, "--memory", "1048"]
      vb.customize ["modifyvm", :id, "--nic1", "nat"]
      vb.customize ["modifyvm", :id, "--nic2", "hostonly"] 
    end
    testvm.vm.provision "shell" do |s|
      s.path = "./vms/install-vms.sh"
      s.args = "testvm"
    end
  end
  
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "cdw-wheezy64-x"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://www.pingworks.net/vagrant/cdw-wheezy64-x.box"
  
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

end
