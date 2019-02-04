#!/bin/bash
set -e

########################################
## Config

proxy_version="`grep proxy versions | awk -F '=' '{print $2}'`"
geth_version="`grep geth versions | awk -F '=' '{print $2}'`"
parity_version="`grep parity versions | awk -F '=' '{print $2}'`"

echo $proxy_version
echo $geth_version
echo $parity_version
exit

name="`whoami`"
cache="4096"
data_dir="/root/eth"

provider="parity"
email="$EMAIL"; [[ -n "$EMAIL" ]] || email="noreply@gmail.com";
domain="$DOMAINNAME"; [[ -n "$DOMAINNAME" ]] || domain="localhost"

project="ethprovider"
registry="docker.io/`whoami`"

proxy_image="$registry/${project}_proxy:$version"
provider_image="$registry/${project}_$provider:$version"

########################################
## Deploy

echo "Deploying images $proxy_image and $provider_image"

tmp=/tmp/ethprovider
mkdir -p $tmp
cat - > $tmp/docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:
  ${provider}_data:
    external: true

services:

  proxy:
    image: $proxy_image
    depends_on:
      - provider
    environment:
      DOMAINNAME: $DOMAINNAME
      EMAIL: $EMAIL
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
      - ${provider}_data:$data_dir
EOF

docker stack deploy --compose-file $tmp/docker-compose.yml eth
