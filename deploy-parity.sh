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
  --detach \
  $image \
  --base-path "/root/eth" \
  --auto-update "all" \
  --cache-size "4096" \
  --no-ui \
  --no-jsonrpc \
  --no-ws \
  --ipc-path "/tmp/ipc/parity.ipc" \
  --ipc-apis "safe,personal" \
  --identity "$me"

