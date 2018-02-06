#!/bin/bash

image="`whoami`/geth:latest"

docker pull $image

docker service create \
  --name "ethprovider_geth" \
  --mode "global" \
  --mount "type=volume,source=geth_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  $image

