#!/bin/bash
set -e

########################################
## Config

provider=parity
email="$EMAIL"; [[ -n "$EMAIL" ]] || email="noreply@gmail.com";
domain="$DOMAINNAME"; [[ -z "$DOMAINNAME" ]] || domain="localhost"

project=ethprovider
registry=docker.io/$(shell whoami)
proxy_image=$registry/${project}_proxy:latest
provider_image=$registry/${project}_$provider:latest

name="bohendo"
cache="4096"
data_dir="/root/eth"

########################################
## Deploy

tmp=/tmp/ethprovider
mkdir -p $tmp
cat - > $tmp/docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:
  ${provider}_data:

services:

  proxy:
    image: $proxy_image
    deploy:
      mode: global
    depends_on:
      - provider
    volumes:
      - certs:/etc/letsencrypt
    ports:
      - "80:80"
      - "443:443"

  provider:
    image: $provider_image
    environment:
      NAME: $name
      DATA_DIR: $data_dir
      CACHE: $cache
    volumes:
      - ${provider}_data:$data_dir
    ports:
      - "30303:30303"
EOF

docker stack deploy --compose-file $tmp/docker-compose.yml eth
