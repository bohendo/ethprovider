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
ETH_VALIDATOR_WALLET="${ETH_VALIDATOR_WALLET:-$(pwd)/.keystore.json}"

mkdir -p "$ETH_1_DATADIR" "$ETH_2_DATADIR"
touch "$ETH_VALIDATOR_WALLET"

project="eth"
proxy_image="${project}_proxy:$(grep proxy versions | awk -F '=' '{print $2}')"
eth1_image="${project}_${ETH_1_CLIENT}:$(grep "$ETH_1_CLIENT" versions | awk -F '=' '{print $2}')"
eth2_image="${project}_${ETH_2_CLIENT}:$(grep "$ETH_2_CLIENT" versions | awk -F '=' '{print $2}')"

########################################
## Setup secrets

secret_name="validator_keystore_password"
if grep -qs "$secret_name\>" <<<"$(docker secret ls)"
then
  echo "A secret called $secret_name already exists, skipping secret setup."
  echo "To overwrite this secret, remove the existing one first: 'docker secret rm $secret_name'"
else
  echo "Enter the $secret_name secret & hit enter (no echo)"
  echo -n "> "
  read -rs secret_value
  echo
  if [[ -z "$secret_value" ]]
  then echo "No secret_value provided, skipping secret creation" && exit 0;
  fi
  if echo "$secret_value" | tr -d '\n\r' | docker secret create "$secret_name" -
  then echo "Successfully saved secret $secret_name"
  else echo "Something went wrong creating a secret called $secret_name" && exit 1
  fi
fi

########################################
## Deploy

echo "Deploying images $proxy_image and $eth1_image"

cat -> docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:

secrets:
  $secret_name:
    external: true

services:

  proxy:
    image: '$proxy_image'
    environment:
      ETH_DOMAINNAME: '$ETH_DOMAINNAME'
      ETH_1_HTTP: '$ETH_1_CLIENT:8545'
      ETH_1_WS: '$ETH_1_CLIENT:8546'
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - 'certs:/etc/letsencrypt'

  $ETH_1_CLIENT:
    image: $eth1_image
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '30303:30303'
    volumes:
      - '$ETH_1_DATADIR:/root/.ethereum'

  $ETH_2_CLIENT:
    image: $eth2_image
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '9000:9000'
    secrets:
      - '$secret_name'
    volumes:
      - '$ETH_2_DATADIR:/root/.lighthouse'
      - '$ETH_VALIDATOR_WALLET:/root/keystore.json'

EOF

docker stack deploy --compose-file docker-compose.yml eth
