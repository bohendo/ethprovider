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
provider_image="${project}_geth:$(grep geth versions | awk -F '=' '{print $2}')"

########################################
## Deploy

echo "Deploying images $proxy_image and $provider_image"

cat -> docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:

services:

  proxy:
    image: $proxy_image
    depends_on:
      - provider
    environment:
      ETHPROVIDER_DOMAINNAME: '$ETHPROVIDER_DOMAINNAME'
      ETHPROVIDER_GETH_HTTP: 'provider:8545'
      ETHPROVIDER_GETH_WS: 'provider:8546'
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
EOF

docker stack deploy --compose-file docker-compose.yml eth
