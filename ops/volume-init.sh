#!/bin/bash

# Sanity check: were we given a hostname?
if [[ -z "$1" || -n "$2" ]]
then
  echo "Provide droplet's hostname as the first arg"
  exit 1
fi

hostname=$1
vol="vol-tor1"
dev="/dev/disk/by-id/scsi-0DO_Volume_$vol"
part="$dev"-part1

# Prepare to set or use our user's password
echo "Enter sudo password for REMOTE machine's user (no echo)"
echo -n "> "
read -s password
echo

ssh $hostname "sudo -S bash -s" <<EOF
$password

if [[ ! -e "$dev" ]]
then
  echo "Volume $vol isn't available to this machine, use the DigitalOcean admin panel to attach it"
  exit 1
fi

if [[ -d "/mnt/$vol/lost+found" ]]
then
  echo "Volume $vol is already mounted & ready to go"
  exit 0
fi

mkdir -p /mnt/$vol

if [[ -z "\`grep $vol /etc/fstab\`" ]]
then
  echo "$part /mnt/$vol ext4 defaults,nofail,discard 0 2" >> /etc/fstab
fi

mount -a

if [[ ! -L /var/lib/docker/volumes ]]
then
  systemctl stop docker
  mv -f /var/lib/docker/volumes /mnt/$vol/old-volumes
  ln -s /mnt/$vol/volumes /var/lib/docker/volumes
  systemctl start docker
fi

reboot

EOF
