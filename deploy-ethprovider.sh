#!/bin/bash

model=geth

image="`whoami`/$model:latest"

docker pull $image

docker service create \
  --name "ethprovider" \
  --mode "global" \
  --mount "type=volume,source=""$model""_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  $image

