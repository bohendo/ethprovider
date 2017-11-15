#!/bin/bash

function err { >&2 echo "Error: $1"; exit 1; }

# We expect the name of a volume as the first & only arg
if [[ -z $1 || -n $2 ]]
then
  err "Provide the name of a volume as the first & only argument"
fi

vol="$1"
dev="/dev/disk/by-id/scsi-0DO_Volume_$vol"
part="$dev"-part1

if [[ -d "/mnt/$vol" ]]
then
  err "Volume $vol is already initialized"
fi

sudo parted $dev mklabel gpt
sudo parted -a opt $dev mkpart primary ext4 0% 100%
sudo mkfs.ext4 $part
sudo mkdir -p /mnt/$vol
echo "$part /mnt/$vol ext4 defaults,nofail,discard 0 2" | sudo tee -a /etc/fstab
sudo mount -a

sudo mkdir -p /mnt/$vol/ethereum
sudo chown -R `whoami`:`whoami` /mnt/$vol/ethereum

ln -Tfs /mnt/$vol/ethereum $HOME/.ethereum

