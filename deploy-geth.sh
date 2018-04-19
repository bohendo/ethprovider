#!/bin/bash
set -e

v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username
image="$me/ethprovider_geth:$v"

mkdir -p /tmp/geth
cat - > /tmp/geth/Dockerfile <<EOF
FROM ethereum/client-go:v1.8.4 as base
FROM alpine:latest
COPY --from=base /usr/local/bin/geth /usr/local/bin
RUN apk add --no-cache ca-certificates
RUN mkdir /root/eth && mkdir /tmp/ipc
ENTRYPOINT ["/usr/local/bin/geth"]
EOF

docker build -f /tmp/geth/Dockerfile -t $image /tmp/geth
rm /tmp/geth/Dockerfile

docker service create \
  --name "ethprovider_geth" \
  --mode "global" \
  --mount "type=volume,source=geth_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --detach \
  $image \
  --datadir "/root/eth" \
  --cache "4096" \
  --rpc \
  --rpcaddr "0.0.0.0" \
  --rpcvhosts "ethprovider_geth" \
  --ipcpath "/tmp/ipc/geth.ipc" \
  --lightserv "50" \
  --identity "$me" \

