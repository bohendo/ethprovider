#!/bin/bash
set -e

########################################
## Config

# shellcheck disable=SC1091
if [[ -f ".env" ]]; then source ".env"; fi

ETHPROVIDER_DOMAINNAME="${ETHPROVIDER_DOMAINNAME:-localhost}"
ETHPROVIDER_DATADIR="${ETHPROVIDER_DATADIR:-/root/eth}"

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
  geth_data:
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
      NAME: $(whoami)
      DATA_DIR: $ETHPROVIDER_DATADIR
      CACHE: 4096
    logging:
      driver: "json-file"
      options:
          max-file: 10
          max-size: 10m
    ports:
      - "30303:30303"
    volumes:
      - geth_data:$ETHPROVIDER_DATADIR
EOF

docker stack deploy --compose-file docker-compose.yml eth
