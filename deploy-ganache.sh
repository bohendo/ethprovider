#!/bin/bash
set -e

v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username
image="$me/ethprovider_ganache:$v"

mkdir -p /tmp/ganache
cat - > /tmp/ganache/Dockerfile <<EOF
FROM node:9.7-alpine
RUN apk --no-cache add git curl
RUN npm install -g ganache-cli@beta
ENTRYPOINT ["ganache-cli"]
EOF

docker build -f /tmp/ganache/Dockerfile -t $image /tmp/ganache
rm /tmp/ganache/Dockerfile

docker service create \
  --name "ethprovider_ganache" \
  --mode "global" \
  --publish "8545:8545" \
  --mount "type=volume,source=ganache_data,target=/root/ganache" \
  --detach \
  $image \
  --gasLimit "12000000" \
  --db "/root/ganache" \
  --port "8545" \
  --networkId "5777" \
  --mnemonic "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat" \

