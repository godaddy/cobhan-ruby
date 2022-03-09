# -*- mode: ruby -*-
# vi: set ft=ruby :

SCRIPT = <<~SCRIPT
set -e

# Update system
sudo apt-get update

echo "Install RVM"
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm

RUBY_VERSION=3.1.0
echo "Install Ruby $RUBY_VERSION"
rvm install $RUBY_VERSION

echo "Install git"
sudo apt-get install git -y

echo "Install docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce -y

sudo gpasswd -a $USER docker
sudo systemctl restart docker.service
sudo systemctl enable docker.service
SCRIPT

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/focal64'
  config.vm.provision 'shell', inline: SCRIPT, privileged: false
end
