#!/bin/bash
set -e

v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username
image="$me/ethprovider_parity:$v"

mkdir -p /tmp/parity
cat - > /tmp/parity/Dockerfile <<EOF
FROM ubuntu:16.04
RUN apt-get update -y && apt-get install -y bash sudo curl
RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh
ENTRYPOINT ["/usr/bin/parity"]
EOF

docker build -f /tmp/parity/Dockerfile -t $image /tmp/parity
rm /tmp/parity/Dockerfile

docker service create \
  --name "ethprovider_parity" \
  --mode "global" \
  --mount "type=volume,source=parity_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --publish "8545:8545" \
  --publish "8546:8546" \
  --detach \
  $image \
  --base-path "/root/eth" \
  --auto-update "all" \
  --cache-size "2048" \
  --no-ui \
  --jsonrpc-port "8545" \
  --jsonrpc-interface "all" \
  --jsonrpc-apis "safe" \
  --jsonrpc-hosts "all" \
  --jsonrpc-cors "all" \
  --ws-port "8546" \
  --ws-interface "all" \
  --ws-apis "safe" \
  --ws-origins "all" \
  --ws-hosts "all" \
  --ipc-path "/tmp/ipc/parity.ipc" \
  --ipc-apis "safe,personal" \
  --identity "$me"

