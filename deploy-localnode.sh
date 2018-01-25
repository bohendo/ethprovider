#!/bin/bash

image="`whoami`/localnode:latest"

docker pull $image

docker service create \
  --name "ethprovider" \
  --mode "global" \
  --mount "type=volume,source=ethprovider_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --publish "8545:8545" \
  --detach \
  $image

