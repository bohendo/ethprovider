#!/bin/bash

function err { >&2 echo "Error: $1"; exit 1; }

vol="vol-tor1"
dev="/dev/disk/by-id/scsi-0DO_Volume_$vol"
part="$dev"-part1

if [[ ! -e "$dev" ]]
then
  err "Volume $vol isn't available to this machine, use the DigitalOcean admin panel to attach it"
fi

if [[ -d "/mnt/$vol/lost+found" ]]
then
  err "Volume $vol is already mounted & ready to go"
fi

sudo mkdir /mnt/$vol
echo "$part /mnt/$vol ext4 defaults,nofail,discard 0 2" | sudo tee -a /etc/fstab
sudo mount -a

sudo mv -f /var/lib/docker/volumes /mnt/$vol/old-volumes

sudo ln -s /mnt/$vol/volumes /var/lib/docker/volumes

# Print results, did everything turn out alright?
docker volume ls

