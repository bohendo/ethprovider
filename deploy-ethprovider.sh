#!/bin/bash

docker pull `whoami`/ethprovider:latest

docker service create \
  --name "ethprovider" \
  --mode "global" \
  --secret "eth_keyfile" \
  --mount "type=volume,source=ethprovider_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  `whoami`/ethprovider:latest

