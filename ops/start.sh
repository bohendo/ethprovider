#!/bin/bash
set -e

########################################
## Config

# shellcheck disable=SC1091
if [[ -f ".env" ]]; then source ".env"; fi

ETH_DATADIR="${ETH_DATADIR:-/data/geth}"
ETH_DOMAINNAME="${ETH_DOMAINNAME:-localhost}"
ETH_NAME="${ETH_NAME:-$(whoami)}"

mkdir -p "$ETH_DATADIR"

project="ethprovider"
proxy_image="${project}_proxy:$(grep proxy versions | awk -F '=' '{print $2}')"
geth_image="${project}_geth:$(grep geth versions | awk -F '=' '{print $2}')"
lighthouse_image="sigp/lighthouse:v$(grep lighthouse versions | awk -F '=' '{print $2}')"

########################################
## Deploy

echo "Deploying images $proxy_image and $geth_image"

cat -> docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:

services:

  proxy:
    image: $proxy_image
    environment:
      ETH_DOMAINNAME: '$ETH_DOMAINNAME'
      ETH_GETH_HTTP: 'geth:8545'
      ETH_GETH_WS: 'geth:8546'
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

  geth:
    image: $geth_image
    environment:
      IDENTITY: $ETH_NAME
      DATA_DIR: $ETH_DATADIR
    logging:
      driver: "json-file"
      options:
          max-file: 10
          max-size: 10m
    ports:
      - "30303:30303"
    volumes:
      - $ETH_DATADIR:$ETH_DATADIR

  lighthouse:
    image: $lighthouse_image
    logging:
      driver: "json-file"
      options:
          max-file: 10
          max-size: 10m
    ports:
      - "9000:9000"

EOF

docker stack deploy --compose-file docker-compose.yml eth
