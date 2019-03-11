#!/bin/bash

sudo yum install -y https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
sudo yum install -y git puppet-agent ruby

gem install librarian-puppet --no-ri --no-rdoc

sudo rm /etc/puppetlabs/puppet/hiera.yaml
sudo ln -s /home/leon/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml

/home/leon/bin/librarian-puppet install --verbose

sudo /opt/puppetlabs/bin/puppet apply site.pp --modulepath=/home/leon/modules

