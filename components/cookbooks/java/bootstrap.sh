#!/bin/bash
echo "changing DNS"
#grep "http_proxy" /home/vagrant/.bash_profile
#if [ $? -eq 1 ]
#    then
#    sudo printf "export http_proxy=http://proxy.wal-mart.com:9080 \nexport https_proxy=http://proxy.wal-mart.com:9080 \n" >> /home/vagrant/.bash_profile
#    sudo printf "export no_proxy=.local,.wal-mart.com,.wamnetNAD,.walmart.com,.wmlink,.walmartlabs.com\n" >> /home/vagrant/.bash_profile
#fi
sudo printf "search wal-mart.com walmart.com homeoffice.wal-mart.com \nnameserver 172.17.40.10 \nnameserver 172.17.168.10\n" > /etc/resolv.conf
sudo /opt/chef/embedded/bin/gem sources --add http://sourcerepos.walmart.com/gembox/
sudo /opt/chef/embedded/bin/gem sources -r https://rubygems.org/
sudo runuser -l vagrant -c "/opt/chef/embedded/bin/gem sources --add http://sourcerepos.walmart.com/gembox/"
sudo runuser -l vagrant -c "/opt/chef/embedded/bin/gem sources -r https://rubygems.org/"

#wget -O /tmp/install.sh https://omnitruck.chef.io/install.sh --no-check-certificate
echo "downloading base gems"
sudo /opt/chef/embedded/bin/gem install aws-s3 -v 0.6.3 --conservative
sudo /opt/chef/embedded/bin/gem install parallel -v 1.9.0 --conservative
sudo /opt/chef/embedded/bin/gem install i18n -v 0.6.9 --conservative
sudo /opt/chef/embedded/bin/gem install activesupport -v 3.2.11 --conservative
echo "Done"
#echo "install zip and unzip"
#sudo yum install zip unzip -y
#echo "Done"
#echo "setting DNS"
#printf "search wal-mart.com walmart.com homeoffice.wal-mart.com \nnameserver 172.17.40.10 \nnameserver 172.17.168.10\n" > /etc/resolv.conf