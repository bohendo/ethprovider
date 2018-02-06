#!/bin/bash

image="`whoami`/parity:latest"

docker pull $image

docker service create \
  --name "ethprovider_parity" \
  --mode "global" \
  --mount "type=volume,source=parity_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  $image

