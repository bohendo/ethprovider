#!/bin/bash

docker build -f Dockerfile -t `whoami`/ethprovider:latest -t ethprovider:latest .

docker service create \
  --name "ethprovider" \
  --mode "global" \
  --secret "eth_keyfile" \
  --mount "type=volume,source=ethprovider_chaindata,destination=/root/.ethereum/geth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  ethprovider:latest

