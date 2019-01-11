#!/bin/bash
set -e

########################################
## Config

version=1.1.0
name="`whoami`"
cache="4096"
data_dir="/root/eth"

provider="parity"
email="$EMAIL"; [[ -n "$EMAIL" ]] || email="noreply@gmail.com";
domain="$DOMAINNAME"; [[ -n "$DOMAINNAME" ]] || domain="localhost"
mode="$MODE"; [[ -n "$mode" ]] || mode="dev"

project="ethprovider"
registry="docker.io/`whoami`"

if [[ "$mode" != "live" ]]
then version=latest
fi

proxy_image="$registry/${project}_proxy:$version"
provider_image="$registry/${project}_$provider:$version"

########################################
## Deploy

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
