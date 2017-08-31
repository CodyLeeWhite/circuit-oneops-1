#!/bin/bash

useProxy=true

#custom repos for gems and yum.
yumRepoBase=http://repos.walmart.com/base/centos/7.2/os/
yumRepoExtras=http://repos.walmart.com/base/centos/7.2/extras/
yumRepoUpdates=http://repos.walmart.com/base/centos/7.2/updates/
yumConfigRepo=http://repos.walmart.com/epel/7/
yumConfigRepoPath=/etc/yum.repos.d/repos.walmart.com_epel_7_.repo
gemRepo="http://sourcerepos.walmart.com/gembox/"

#user set in .kitchen.yml. default is vagrant
kitchenUser=vagrant

if [ "$useProxy" = true ] ; then
    echo "setting up proxy"
    sudo yum clean all
    echo "setting yum to use proxy"
    echo "removing default repos from yum"
    sudo rm -rf /etc/yum.repos.d/*
    echo "adding custom repo to yum"
    echo "[base]" > /etc/yum.repos.d/base.repo
    echo name=base >> /etc/yum.repos.d/base.repo
    echo baseurl=$yumRepoBase >> /etc/yum.repos.d/base.repo
    echo enabled=1 >> /etc/yum.repos.d/base.repo
    echo gpgcheck=0 >> /etc/yum.repos.d/base.repo
    echo "[extras]" > /etc/yum.repos.d/extras.repo
    echo name=extras >> /etc/yum.repos.d/extras.repo
    echo baseurl=$yumRepoExtras >> /etc/yum.repos.d/extras.repo
    echo enabled=1 >> /etc/yum.repos.d/extras.repo
    echo gpgcheck=0 >> /etc/yum.repos.d/extras.repo
    echo "[updates]" > /etc/yum.repos.d/updates.repo
    echo name=updates >> /etc/yum.repos.d/updates.repo
    echo baseurl=$yumRepoUpdates >> /etc/yum.repos.d/updates.repo
    echo enabled=1 >> /etc/yum.repos.d/updates.repo
    echo gpgcheck=0 >> /etc/yum.repos.d/updates.repo
    sudo yum -d0 -e0 -y install rsync yum-utils
    sudo yum-config-manager --add-repo $yumConfigRepo
    echo gpgcheck=0 >> $yumConfigRepoPath
    sudo yum -q makecache

    echo "setting url for internal gem repo"
    sudo /opt/chef/embedded/bin/gem sources --add $gemRepo
    sudo /opt/chef/embedded/bin/gem sources -r https://rubygems.org/
    sudo runuser -l $kitchenUser -c "/opt/chef/embedded/bin/gem sources --add $gemRepo"
    sudo runuser -l $kitchenUser -c "/opt/chef/embedded/bin/gem sources -r https://rubygems.org/"


    #install base rpm packages
    sudo yum -d0 -e0 -y install sudo file make gcc gcc-c++ glibc-devel libgcc ruby ruby-libs ruby-devel libxml2-devel libxslt-devel ruby-rdoc rubygems perl perl-Digest-MD5 nagios nagios-devel nagios-plugins
fi

echo "downloading base gems"
sudo /opt/chef/embedded/bin/gem install aws-s3 -v 0.6.3 --conservative
sudo /opt/chef/embedded/bin/gem install parallel -v 1.9.0 --conservative
sudo /opt/chef/embedded/bin/gem install i18n -v 0.6.9 --conservative
sudo /opt/chef/embedded/bin/gem install activesupport -v 3.2.11 --conservative
echo "Done"



#
# Install ruby and bundle for chef or puppet, oneops user, sshd config
#

#
#sudo yum clean all
#echo "[base]" > /etc/yum.repos.d/base.repo
#echo name=base >> /etc/yum.repos.d/base.repo
#echo baseurl=http://repos.walmart.com/base/centos/7.2/os/ >> /etc/yum.repos.d/base.repo
#echo enabled=1 >> /etc/yum.repos.d/base.repo
#echo gpgcheck=0 >> /etc/yum.repos.d/base.repo
#echo "[extras]" > /etc/yum.repos.d/extras.repo
#echo name=extras >> /etc/yum.repos.d/extras.repo
#echo baseurl=http://repos.walmart.com/base/centos/7.2/extras/ >> /etc/yum.repos.d/extras.repo
#echo enabled=1 >> /etc/yum.repos.d/extras.repo
#echo gpgcheck=0 >> /etc/yum.repos.d/extras.repo
#echo "[updates]" > /etc/yum.repos.d/updates.repo
#echo name=updates >> /etc/yum.repos.d/updates.repo
#echo baseurl=http://repos.walmart.com/base/centos/7.2/updates/ >> /etc/yum.repos.d/updates.repo
#echo enabled=1 >> /etc/yum.repos.d/updates.repo
#echo gpgcheck=0 >> /etc/yum.repos.d/updates.repo
#sudo yum -d0 -e0 -y install rsync yum-utils
#sudo yum-config-manager --add-repo http://repos.walmart.com/epel/7/
#echo gpgcheck=0 >> /etc/yum.repos.d/repos.walmart.com_epel_7_.repo
#sudo yum -q makecache

#declare -A myArgs
#myArgs["rubygems"]=http://repos.walmart.com/gemrepo/
#myArgs["rubygemsbkp"]=http://repos.walmart.com/gemrepo/
#myArgs["misc"]=http://repos.walmart.com/mirrored-assets/apache.mirrors.pair.com/
#myArgs["http:"]=http://proxy.wal-mart.com:9080
#myArgs["https:"]=http://proxy.wal-mart.com:9080
#myArgs["no:"]=.local,.wal-mart.com,.wamnetNAD,.walmart.com,.wmlink,.walmartlabs.com
#set -e
#
#if ! [ -e /etc/ssh/ssh_host_dsa_key ] ; then
#  echo "generating host ssh keys"
#  /usr/bin/ssh-keygen -A
#fi
#
#for ARG in "$myArgs"
#do
#  # if arg starts with http then use it to set http_proxy env variable
#  if [[ $ARG == http:* ]] ; then
#	http_proxy=${ARG/http:/}
#    echo "exporting http_proxy=$http_proxy"
#    export http_proxy=$http_proxy
#  elif [[ $ARG == https:* ]] ; then
#	https_proxy=${ARG/https:/}
#    echo "exporting https_proxy=$https_proxy"
#    export https_proxy=$https_proxy
#  elif [[ $ARG == no:* ]] ; then
#	no_proxy=${ARG/no:/}
#    echo "exporting no_proxy=$no_proxy"
#    export no_proxy=$no_proxy
#  elif [[ $ARG == rubygems:* ]] ; then
#    rubygems_proxy=${ARG/rubygems:/}
#    echo "exporting rubygems_proxy=$rubygems_proxy"
#    export rubygems_proxy=$rubygems_proxy
#  elif [[ $ARG == misc:* ]] ; then
#    misc_proxy=${ARG/misc:/}
#    echo "exporting misc_proxy=$misc_proxy"
#    export misc_proxy=$misc_proxy
#  fi
#done
#
## setup os release variables
#echo "Install ruby and bundle."
#
## sles or opensuse
#if [ -e /etc/SuSE-release ] ; then
#  zypper -n in sudo rsync file make gcc glibc-devel libgcc ruby ruby-devel rubygems libxml2-devel libxslt-devel perl
#  zypper -n in rubygem-yajl-ruby
#
#  # sles
#  hostname=`cat /etc/HOSTNAME`
#  grep $hostname /etc/hosts
#  if [ $? != 0 ]; then
#    ip_addr=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/' | xargs`
#    echo "$ip_addr $hostname" >> /etc/hosts
#  fi
#
## redhat / centos
#elif [ -e /etc/redhat-release ] ; then
#  echo "installing ruby, libs, headers and gcc"
#  yum -d0 -e0 -y install sudo file make gcc gcc-c++ glibc-devel libgcc ruby ruby-libs ruby-devel libxml2-devel libxslt-devel ruby-rdoc rubygems perl perl-Digest-MD5 nagios nagios-devel nagios-plugins
#
#  # disable selinux
#  if [ -e /selinux/enforce ]; then
#    echo 0 >/selinux/enforce
#    echo "SELINUX=disabled" >/etc/selinux/config
#	echo "SELINUXTYPE=targeted" >>/etc/selinux/config
#  fi
#
#  # allow ssh sudo's w/out tty
#  grep -v requiretty /etc/sudoers > /etc/sudoers.t
#  mv -f /etc/sudoers.t /etc/sudoers
#  chmod 440 /etc/sudoers
#
#else
## debian
#	export DEBIAN_FRONTEND=noninteractive
#	echo "apt-get update ..."
#	apt-get update >/dev/null 2>&1
#	if [ $? != 0 ]; then
#	   echo "apt-get update returned non-zero result code. Usually means some repo is returning a 403 Forbidden. Try deleting the compute from providers console and retrying."
#	   exit 1
#	fi
#	apt-get install -q -y build-essential make libxml2-dev libxslt-dev libz-dev ruby ruby-dev nagios3
#
#	# seperate rubygems - rackspace 14.04 needs it, aws doesn't
#	set +e
#	apt-get -y -q install rubygems-integration
#	rm -fr /etc/apache2/conf.d/nagios3.conf
#	set -e
#fi
#
#me=`logname`
#base_path="/home/$me"
#
#if [ "$me" == "root" ] ; then
#  base_path="/root"
#fi
#local_gems="$base_path/shared/cookbooks/vendor/cache/"
#
#set +e
#gem source | grep $local_gems
#if [ $? != 0 ]; then
#  gem source --add file://$local_gems
#  gem source --remove 'http://rubygems.org/'
#  gem source
#fi
#
#if [ -n "$rubygems_proxy" ]; then
#  proxy_exists=`gem source | grep $rubygems_proxy | wc -l`
#  if [ $proxy_exists == 0 ] ; then
#    gem source --remove $rubygems_proxy
#    gem source --remove 'http://rubygems.org/'
#    gem source --remove 'https://rubygems.org/'
#    gem source
#  fi
#else
#  rubygems_proxy="https://rubygems.org"
#fi
#
#cd $local_gems
#
#if [ -e /etc/redhat-release ] ; then
#	# needed for rhel >= 7
#	gem update --system 1.8.25
#   if [ $? -ne 0 ]; then
#     gem source --remove file://$local_gems
#     gem source --add $rubygems_proxy
#     set -e
#     gem update --system 1.8.25
#     set +e
#   fi
#fi
#
#gem_version="1.7.7"
#grep 16.04 /etc/issue
#if [ $? -eq 0 ]
#then
#  gem_version="2.0.2"
#fi
#
#gem install json --version $gem_version --no-ri --no-rdoc
#if [ $? -ne 0 ]; then
#    echo "gem install using local repo failed. reverting to rubygems proxy."
#    gem source --add $rubygems_proxy
#    gem source --remove file://$local_gems
#    gem source --remove 'http://rubygems.org/'
#    gem source
#    gem install json --version $gem_version --no-ri --no-rdoc
#    if [ $? -ne 0 ]; then
#      echo "could not install json gem"
#      exit 1
#    fi
#fi
#
#set -e
#gem install bundler --bindir /usr/bin --no-ri --no-rdoc
#
#mkdir -p /opt/oneops
#echo "$rubygems_proxy" > /opt/oneops/rubygems_proxy
#
#set +e
#perl -p -i -e 's/ 00:00:00.000000000Z//' /var/lib/gems/*/specifications/*.gemspec 2>/dev/null
#
## oneops user
#grep "^oneops:" /etc/passwd 2>/dev/null
#if [ $? != 0 ] ; then
#    set -e
#	echo "*** ADD oneops USER ***"
#
#	# create oneops user & group - deb systems use addgroup
#	if [ -e /etc/lsb-release] ] ; then
#		addgroup oneops
#	else
#		groupadd oneops
#	fi
#
#	useradd oneops -g oneops -m -s /bin/bash
#	echo "oneops   ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
#else
#	echo "oneops user already there..."
#fi
#set -e
#
## ssh and components move
#if [ "$me" == "oneops" ] ; then
#  exit
#fi
#
#echo "copying files from provider-setup user $me to oneops..."
#
#home_dir="/home/$me"
#if [ "$me" == "root" ] ; then
#  cd /root
#  home_dir="/root"
#else
#  cd /home/$me
#fi
#
#me_group=$me
#if [ -e /etc/SuSE-release ] ; then
#  me_group="users"
#fi
#
#pwd
## gets rid of the 'only use ec2-user' ssh response
#sed -e 's/.* ssh-rsa/ssh-rsa/' .ssh/authorized_keys > .ssh/authorized_keys_
#mv .ssh/authorized_keys_ .ssh/authorized_keys
#chown $me:$me_group .ssh/authorized_keys
#chmod 600 .ssh/authorized_keys
#
## ibm rhel
#if [ "$me" != "root" ] ; then
#  `rsync -a /home/$me/.ssh /home/oneops/`
#else
#  `cp -r ~/.ssh /home/oneops/.ssh`
#  `cp ~/.ssh/authorized_keys /home/oneops/.ssh/authorized_keys`
#fi
#
#if [ "$me" == "idcuser" ] ; then
#  echo 0 > /selinux/enforce
#  # need to set a password for the rhel 6.3
#  openssl rand -base64 12 | passwd oneops --stdin
#fi
#
#mkdir -p /opt/oneops/workorder /etc/nagios/conf.d /var/log/nagios
#rsync -a $home_dir/circuit-oneops-1 /home/oneops/
#rsync -a $home_dir/shared /home/oneops/
#chown -R oneops:oneops /home/oneops /opt/oneops
