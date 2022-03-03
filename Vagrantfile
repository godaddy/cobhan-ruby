# -*- mode: ruby -*-
# vi: set ft=ruby :

SCRIPT = <<~SCRIPT
set -e

echo "Install RVM"
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm

RUBY_VERSION=3.1.0
echo "Install Ruby $RUBY_VERSION"
rvm install $RUBY_VERSION

echo "Install git"
sudo yum install git -y

echo "Install docker"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo usermod -aG docker $USER
sudo systemctl start docker.service
sudo systemctl enable docker.service
SCRIPT

Vagrant.configure('2') do |config|
  config.vm.box = 'centos/7'
  config.vm.provision 'shell', inline: SCRIPT, privileged: false
end
