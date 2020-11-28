#!/bin/bash
set -e

########################################
## Config

# shellcheck disable=SC1091
if [[ -f ".env" ]]; then source ".env"; fi

ETH_1_CLIENT="${ETH_1_CLIENT:-geth}"
ETH_2_CLIENT="${ETH_2_CLIENT:-lighthouse}"
ETH_1_DATADIR="${ETH_1_DATADIR:-/data/$ETH_1_CLIENT}"
ETH_2_DATADIR="${ETH_2_DATADIR:-/data/$ETH_2_CLIENT}"
ETH_DOMAINNAME="${ETH_DOMAINNAME:-localhost}"
ETH_IDENTITY="${ETH_IDENTITY:-$(whoami)}"

mkdir -p "$ETH_1_DATADIR" "$ETH_2_DATADIR"

project="eth"
proxy_image="${project}_proxy:$(grep proxy versions | awk -F '=' '{print $2}')"
eth1_image="${project}_geth:$(grep geth versions | awk -F '=' '{print $2}')"
eth2_image="sigp/lighthouse:v$(grep lighthouse versions | awk -F '=' '{print $2}')"

########################################
## Deploy

echo "Deploying images $proxy_image and $eth1_image"

cat -> docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:

services:

  proxy:
    image: '$proxy_image'
    environment:
      ETH_DOMAINNAME: '$ETH_DOMAINNAME'
      ETH_1_HTTP: 'eth1:8545'
      ETH_1_WS: 'eth1:8546'
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - 'certs:/etc/letsencrypt'

  eth1:
    image: $eth1_image
    environment:
      IDENTITY: $ETH_IDENTITY
      DATA_DIR: $ETH_1_DATADIR
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '30303:30303'
    volumes:
      - '$ETH_1_DATADIR:/root/.ethereum'

  eth2:
    image: $eth2_image
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '9000:9000'
    volumes:
      - '$ETH_2_DATADIR:/root/.lighthouse'

EOF

docker stack deploy --compose-file docker-compose.yml eth
