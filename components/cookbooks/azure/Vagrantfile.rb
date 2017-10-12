# -*- mode: ruby -*-
# vi: set ft=ruby :

# test setting a guest environment variable based on a host environment variable
# if FOO_BAR is set locally, create command to add it to .profile in the guest
value1 = ""
value2 = ""
value3 = ""
value4 = ""
value5 = ""
value6 = ""
value7 = ""
puts ENV['yumRepoBase']
if ENV['yumRepoBase']
  value1 = ENV['yumRepoBase']
end
if ENV['yumRepoExtras']
  value2 = ENV['yumRepoExtras']
end
if ENV['yumRepoUpdates']
  value3 = ENV['yumRepoUpdates']
end
if ENV['yumConfigRepo']
  value4 = ENV['yumConfigRepo']
end
if ENV['yumConfigRepoPath']
  value5 = ENV['yumConfigRepoPath']
end
if ENV['gemRepo']
  value6 = ENV['gemRepo']
end
if ENV['use_proxy']
  value7 = ENV['use_proxy']
end
script = <<SCRIPT
echo "export yumRepoBase=#{value1}" | sudo tee -a /etc/environment
echo "export yumRepoExtras=#{value2}" | sudo tee -a /etc/environment
echo "export yumRepoUpdates=#{value3}" | sudo tee -a /etc/environment
echo "export yumConfigRepo=#{value4}" | sudo tee -a /etc/environment
echo "export yumConfigRepoPath=#{value5}" | sudo tee -a /etc/environment
echo "export gemRepo=#{value6}" | sudo tee -a /etc/environment
echo "export use_proxy=#{value7}" | sudo tee -a /etc/environment
SCRIPT
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision :shell, :inline => script
end