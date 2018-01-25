#!/bin/bash

image="`whoami`/ethprovider:latest"

docker pull $image

docker service create \
  --name "ethprovider" \
  --mode "global" \
  --mount "type=volume,source=ethprovider_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  $image

