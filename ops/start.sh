#!/bin/bash
set -e

stack="eth"

# make sure a network for this project has been created
docker swarm init 2> /dev/null || true

if grep -qs "$stack" <<<"$(docker stack ls --format '{{.Name}}')"
then echo "An $stack stack is already running" && exit 0;
else echo; echo "Preparing to launch $stack stack"
fi

########################################
## Config

# shellcheck disable=SC1091
if [[ -f ".env" ]]; then source ".env"; fi

ETH_1_CLIENT="${ETH_1_CLIENT:-geth}"
ETH_2_CLIENT="${ETH_2_CLIENT:-lighthouse}"
ETH_1_DATADIR="${ETH_1_DATADIR:-/data/$ETH_1_CLIENT}"
ETH_2_DATADIR="${ETH_2_DATADIR:-/data/$ETH_2_CLIENT}"
ETH_2_ETH1_URL="${ETH_2_ETH1_URL:-http://eth1:8545}"
ETH_API_KEY="${ETH_API_KEY:-abc123}"
ETH_DOMAINNAME="${ETH_DOMAINNAME:-localhost}"

mkdir -p "$ETH_1_DATADIR" "$ETH_2_DATADIR"

proxy_image="${stack}_proxy:v$(grep proxy versions | awk -F '=' '{print $2}')"
eth1_image="${stack}_${ETH_1_CLIENT}:v$(grep "$ETH_1_CLIENT" versions | awk -F '=' '{print $2}')"
eth2_image="${stack}_${ETH_2_CLIENT}:v$(grep "$ETH_2_CLIENT" versions | awk -F '=' '{print $2}')"

########################################
## Setup secrets

password_secret="validator_keystore_password"
if grep -qs "$password_secret\>" <<<"$(docker secret ls)"
then
  echo "A secret called $password_secret already exists, skipping secret setup."
  echo "To overwrite this secret, remove the existing one first: 'docker secret rm $password_secret'"
else
  echo "Enter the $password_secret secret & hit enter (no echo)"
  echo -n "> "
  read -rs secret_value
  echo
  if [[ -z "$secret_value" ]]
  then echo "No secret_value provided, skipping secret creation" && exit 0;
  fi
  if echo "$secret_value" | tr -d '\n\r' | docker secret create "$password_secret" -
  then echo "Successfully saved secret $password_secret"
  else echo "Something went wrong creating a secret called $password_secret" && exit 1
  fi
fi

########################################
## Deploy

echo "Deploying images $proxy_image and $eth1_image"

logging="logging:
      driver: 'json-file'
      options:
          max-size: '100m'"

cat -> docker-compose.yml <<EOF
version: '3.4'

volumes:
  certs:

secrets:
  $password_secret:
    external: true

services:

  proxy:
    image: '$proxy_image'
    environment:
      ETH_1_HTTP: 'eth1:8545'
      ETH_1_WS: 'eth1:8546'
      ETH_2_HTTP: 'beacon:5052'
      ETH_2_WS: 'beacon:5053'
      ETH_API_KEY: '$ETH_API_KEY'
      ETH_DOMAINNAME: '$ETH_DOMAINNAME'
    $logging
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - 'certs:/etc/letsencrypt'

  eth1:
    image: $eth1_image
    $logging
    ports:
      - '30303:30303'
    volumes:
      - '$ETH_1_DATADIR:/root/.ethereum'

  beacon:
    image: $eth2_image
    environment:
      ETH_2_ETH1_URL: '$ETH_2_ETH1_URL'
      ETH_2_MODULE: 'beacon'
      ETH_2_NETWORK: 'mainnet'
    $logging
    volumes:
      - '$ETH_2_DATADIR:/root/.lighthouse'

  validator:
    image: $eth2_image
    environment:
      ETH_2_BEACON_URL: 'http://beacon:5052'
      ETH_2_MODULE: 'validator'
      ETH_2_NETWORK: 'mainnet'
    $logging
    secrets:
      - '$password_secret'
    volumes:
      - '$ETH_2_DATADIR:/root/.lighthouse'

EOF

docker stack deploy --compose-file docker-compose.yml $stack
