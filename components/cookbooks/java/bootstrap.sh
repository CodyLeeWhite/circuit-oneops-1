#!/bin/bash

useProxy = true
#proxy variables
myProxy = "http://proxy.wal-mart.com:9080"
noProxy = ".local,.wal-mart.com,.wamnetNAD,.walmart.com,.wmlink,.walmartlabs.com"

#custom repos for gems and yum.
yumRepo = "http://repos.walmart.com/base/centos/6.8"
gemRepo = "http://sourcerepos.walmart.com/gembox/"

if [ "$useProxy" = true ] ; then
    echo "setting up proxy for user Vagrant"
    grep "http_proxy" /home/vagrant/.bashrc
    if [ $? -eq 1 ]
        then
        sudo printf "export http_proxy=$myProxy \nexport https_proxy=$myProxy \n" >> /home/vagrant/.bashrc
        sudo printf "export no_proxy=$noProxy\n" >> /home/vagrant/.bashrc
        echo "setting yum to use proxy"
        echo "removing default repos from yum"
        sudo rm -rf /etc/yum.repos.d/*
        echo "adding custom repo to yum"
        sudo printf "[myrepo] \nname=customRepo \nbaseurl=$yumRepo \n" > /etc/yum.repos.d/Centos-Base.repo
    fi

    echo "setting url for internal gem repo"
    sudo /opt/chef/embedded/bin/gem sources --add $gemRepo
    sudo /opt/chef/embedded/bin/gem sources -r https://rubygems.org/
    sudo runuser -l vagrant -c "/opt/chef/embedded/bin/gem sources --add $gemRepo"
    sudo runuser -l vagrant -c "/opt/chef/embedded/bin/gem sources -r https://rubygems.org/"
fi

echo "downloading base gems"
sudo /opt/chef/embedded/bin/gem install aws-s3 -v 0.6.3 --conservative
sudo /opt/chef/embedded/bin/gem install parallel -v 1.9.0 --conservative
sudo /opt/chef/embedded/bin/gem install i18n -v 0.6.9 --conservative
sudo /opt/chef/embedded/bin/gem install activesupport -v 3.2.11 --conservative
echo "Done"

echo "install zip and unzip"
sudo yum clean metadata
sudo yum install zip unzip -y