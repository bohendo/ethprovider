#!/bin/bash
set -e

me=`whoami` # your docker.io username
image="$me/ethprovider_geth:latest"

mkdir -p /tmp/geth
cat - > /tmp/geth/Dockerfile <<EOF
FROM ethereum/client-go:v1.8.7 as base
FROM alpine:latest
COPY --from=base /usr/local/bin/geth /usr/local/bin
RUN apk add --no-cache ca-certificates && mkdir /root/eth && mkdir /tmp/ipc
ENTRYPOINT ["/usr/local/bin/geth"]
EOF

docker build -f /tmp/geth/Dockerfile -t $image /tmp/geth
rm /tmp/geth/Dockerfile

privateip=`ifconfig eth1 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

echo "listening on interface $privateip"

docker container create \
  --name "ethprovider" \
  --mount "type=volume,source=geth_data,destination=/root/eth" \
  --mount "type=volume,source=ethprovider_ipc,destination=/tmp/ipc" \
  --publish "$privateip:8545:8545" \
  $image \
  --datadir "/root/eth" \
  --cache "4096" \
  --rpc \
  --rpcaddr "0.0.0.0" \
  --rpcapi "net,eth" \
  --rpcvhosts "ethprovider" \
  --ipcpath "/tmp/ipc/geth.ipc" \
  --lightserv "50" \
  --identity "$me"

# Docker bug? Gets stuck with status "created"
sleep 1; docker container restart ethprovider; sleep 1

docker container logs -f ethprovider
