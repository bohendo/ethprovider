#!/bin/bash
set -e

########################################
## Config

if [[ "$1" == "geth" ]]
then provider="geth"
else provider="parity"
fi

email="noreply@gmail.com"
[[ -z "$EMAIL" ]] || email="$EMAIL"

domain="localhost"
[[ -z "$DOMAINNAME" ]] || domain="$DOMAINNAME"

me=`whoami`

name="eth_provider"
cache="4096"
http_port="8545"
ws_port="8546"
data_dir="/root/eth"

########################################
## Build Provider

echo;echo "Building Eth Provider";echo
image="$name_$provider:latest"
tmp="/tmp/$name"

mkdir -p $tmp

docker build -f $tmp/$provider.Dockerfile -t $provider_image $tmp/
rm -rf $tmp

########################################
## Build Proxy

echo;echo "Building Eth Proxy";echo

proxy_image="eth_proxy:latest"
tmp="/tmp/eth_proxy"
mkdir -p $tmp

devcerts=/etc/letsencrypt/devcerts

docker build -f $tmp/Dockerfile -t $proxy_image $tmp/
rm -rf $tmp

########################################
## Deploy

echo;echo "Deploying Eth Provider";echo

tmp=/tmp/ethprovider
mkdir -p $tmp

cat - > $tmp/docker-compose.yml <<EOF
version: '3.4'

volumes:
  letsencrypt:
  devcerts:
  ${provider}_data:
    external: true

services:

  proxy:
    image: $proxy_image
    deploy:
      mode: global
    depends_on:
      - provider
    volumes:
      - devcerts:/etc/devcerts
      - letsencrypt:/etc/letsencrypt
    ports:
      - "80:80"
      - "443:443"

  provider:
    image: $provider_image
    deploy:
      mode: global
    volumes:
      - ${provider}_data:$data_dir
    ports:
      - "30303:30303"
EOF

docker stack deploy --compose-file $tmp/docker-compose.yml eth
