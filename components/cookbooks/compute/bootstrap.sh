#!/bin/bash
#echo "export PATH=\"/opt/chef/embedded/bin:$PATH\"" | sudo tee /etc/profile.d/profile.sh
echo "installing base yum packages"
yum -d0 -e0 -y install sudo file make gcc rsync gcc-c++ glibc-devel libgcc ruby ruby-libs ruby-devel libxml2-devel libxslt-devel ruby-rdoc rubygems perl perl-Digest-MD5 nagios nagios-devel nagios-plugins
echo "downloading base gems"
sudo /opt/chef/embedded/bin/gem install rest-client -v 2.0.0.rc2 --pre --conservative
sudo /opt/chef/embedded/bin/gem install nokogiri -v 1.6.8.1 --conservative
sudo /opt/chef/embedded/bin/gem install fog -v 1.41.0 --conservative
sudo /opt/chef/embedded/bin/gem install aws-s3 -v 0.6.3 --conservative
sudo /opt/chef/embedded/bin/gem install parallel -v 1.9.0 --conservative
sudo /opt/chef/embedded/bin/gem install i18n -v 0.6.9 --conservative
sudo /opt/chef/embedded/bin/gem install activesupport -v 3.2.11 --conservative
sudo /opt/chef/embedded/bin/gem install azure_mgmt_resources -v 0.6.0 --conservative
sudo /opt/chef/embedded/bin/gem install azure_mgmt_compute -v 0.6.0 --conservative
sudo /opt/chef/embedded/bin/gem install azure_mgmt_storage -v 0.6.0 --conservative
sudo /opt/chef/embedded/bin/gem install addressable -v 2.3.8 --conservative
sudo /opt/chef/embedded/bin/gem install azure --conservative
sudo /opt/chef/embedded/bin/gem install azure_mgmt_network -v 0.6.0 --conservative
sudo /opt/chef/embedded/bin/gem install excon --conservative
echo "Done"
sudo mkdir -p /opt/oneops/inductor/circuit-oneops-1/components/cookbooks/
sudo mkdir -p /root/shared/cookbooks/vendor/cache/
sudo mkdir -p /root/circuit-oneops-1
sudo cp -r /tmp/kitchen/cookbooks/shared /opt/oneops/inductor/
sudo cp -r /tmp/kitchen/cookbooks/ /opt/oneops/inductor/circuit-oneops-1/components/
sudo cp -r /tmp/kitchen/cookbooks/ /root/circuit-oneops-1/components/