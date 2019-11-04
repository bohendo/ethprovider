#!/bin/bash
set -e

########################################
## Config

ETHPROVIDER_CLIENT="${ETHPROVIDER_IMAGE_TYPE:-geth}"
ETHPROVIDER_BUILD_TYPE="${ETHPROVIDER_BUILD_TYPE:-}"
ETHPROVIDER_EMAIL="${ETHPROVIDER_EMAIL:-noreply@gmail.com}"
ETHPROVIDER_DOMAINNAME="${ETHPROVIDER_DOMAINNAME:-localhost}"

proxy_version="`grep proxy versions | awk -F '=' '{print $2}'`"
geth_version="`grep geth versions | awk -F '=' '{print $2}'`$ETHPROVIDER_BUILD_TYPE"
parity_version="`grep parity versions | awk -F '=' '{print $2}'`$ETHPROVIDER_BUILD_TYPE"

name="`whoami`"
cache="4096"
data_dir="/root/eth"

project="ethprovider"
registry="docker.io/`whoami`"

proxy_image="$registry/${project}_proxy:$proxy_version"
if [[ "$ETHPROVIDER_CLIENT" == "geth" ]]
then provider_image="$registry/${project}_$ETHPROVIDER_CLIENT:$geth_version"
else provider_image="$registry/${project}_$ETHPROVIDER_CLIENT:$parity_version"
fi

########################################
## Deploy

echo "Deploying images $proxy_image and $provider_image"

tmp=/tmp/ethprovider
mkdir -p $tmp
cat - > $tmp/docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:
  ${ETHPROVIDER_CLIENT}_data:
    external: true

services:

  proxy:
    image: $proxy_image
    depends_on:
      - provider
    environment:
      DOMAINNAME: $ETHPROVIDER_DOMAINNAME
      EMAIL: $ETHPROVIDER_EMAIL
    logging:
      driver: "json-file"
      options:
          max-file: 10
          max-size: 10m
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - certs:/etc/letsencrypt

  provider:
    image: $provider_image
    environment:
      NAME: $name
      DATA_DIR: $data_dir
      CACHE: $cache
    logging:
      driver: "json-file"
      options:
          max-file: 10
          max-size: 10m
    ports:
      - "30303:30303"
    volumes:
      - ${ETHPROVIDER_CLIENT}_data:$data_dir
EOF

docker stack deploy --compose-file $tmp/docker-compose.yml eth
