#!/bin/bash

# Once your droplet's awake & your ssh keys are good to go,
# Run this script and pass the droplet's hostname as the first & only argument

# define a clean error handler
function err { >&2 echo "Error: $1"; exit 1; }

# Sanity check: were we given a hostname?
if [[ ! $1 || $2 ]]
then
  err "Provide droplet's hostname as the first arg"
else
  hostname=$1
fi

# Sanity check: Can't login as root? Well then we can't initialize
if ! ssh -q $hostname exit 2> /dev/null
then
  hostname=root@$hostname
  if ! ssh -q $hostname exit 2> /dev/null
  then
    err "Can't connect to $1 or $hostname"
  fi
fi

# Prepare to set or use our user's password
echo "Enter sudo password for REMOTE machine's user (no echo)"
echo -n "> "
read -s password
echo

####################
# Get data to set as environment vars

me=`whoami`

####################
# main heredoc

ssh $hostname "sudo -S bash -s" <<EOF
$password

########################################
# Upgrade Everything

# update & upgrade without prompts
# https://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
apt-get autoremove -y

########################################
# Setup firewall

ufw --force reset
ufw allow 22 &&\
ufw --force enable

########################################
# Install Docker

# Install docker dependencies
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Get the docker team's official gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add the docker repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   \`lsb_release -cs\` \
   stable"

apt-get update -y
apt-get install -y docker-ce

systemctl enable docker

########################################
# Create our non-root user & harden

adduser --gecos "" $me <<EOIF
$password
$password
EOIF
usermod -aG sudo,docker $me

cp -r /root/.ssh /home/$me
cp -r /root/.bash_aliases /home/$me
chown -R $me:$me /home/$me

# Turn off password authentication
sed -i '/PasswordAuthentication/ c\
PasswordAuthentication no
' /etc/ssh/sshd_config

# Turn off root login
sed -i '/PermitRootLogin/ c\
PermitRootLogin no
' /etc/ssh/sshd_config


########################################
# Double-check upgrades

## For some reason, gotta upgrade again to get it all
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
apt-get autoremove -y

EOF

