#!/bin/bash
set -e

########################################
## Config

# shellcheck disable=SC1091
if [[ -f ".env" ]]; then source ".env"; fi

ETHPROVIDER_DATADIR="${ETHPROVIDER_DATADIR:-/data/geth}"
ETHPROVIDER_DOMAINNAME="${ETHPROVIDER_DOMAINNAME:-localhost}"
ETHPROVIDER_NAME="${ETHPROVIDER_NAME:-$(whoami)}"

mkdir -p "$ETHPROVIDER_DATADIR"

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
      ETHPROVIDER_DOMAINNAME: '$ETHPROVIDER_DOMAINNAME'
      ETHPROVIDER_GETH_HTTP: 'geth:8545'
      ETHPROVIDER_GETH_WS: 'geth:8546'
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
      IDENTITY: $ETHPROVIDER_NAME
      DATA_DIR: $ETHPROVIDER_DATADIR
    logging:
      driver: "json-file"
      options:
          max-file: 10
          max-size: 10m
    ports:
      - "30303:30303"
    volumes:
      - $ETHPROVIDER_DATADIR:$ETHPROVIDER_DATADIR

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
