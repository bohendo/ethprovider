#!/bin/bash

if [[ ! -f /swp ]]
then
  sudo fallocate -l 2G /swp
  sudo chmod 600 /swp
  sudo mkswap /swp
fi

if [[ -z "`grep swap /etc/fstab`" ]]
then
  echo '/swp none swap sw 0 0' | sudo tee -a /etc/fstab
fi

sudo swapon -a

# Swap is slow, don't use it unless absolutely necessary
sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

free -h

