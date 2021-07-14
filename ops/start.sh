#!/bin/bash
set -e

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
stack="eth"

# make sure a network for this project has been created
docker swarm init 2> /dev/null || true

if grep -qs "$stack" <<<"$(docker stack ls --format '{{.Name}}')"
then echo "An $stack stack is already running" && exit 0;
else echo; echo "Preparing to launch $stack stack"
fi

########################################
## Hardcoded Config

beacon_internal_port="5025"
eth1_http_port="8545"
eth1_ws_port="8546"

########################################
## Customizable Config

# shellcheck disable=SC1091
if [[ -f ".env" ]]; then source ".env"; fi

ETH_1_CACHE="${ETH_1_CACHE:-2048}"
ETH_1_DATADIR="${ETH_1_DATADIR:-geth}"
ETH_1_LIGHT_SERVE="${ETH_1_LIGHT_SERVE:-20}"
ETH_2_DATADIR="${ETH_2_DATADIR:-lighthouse}"
ETH_2_ETH1_URL="${ETH_2_ETH1_URL:-http://eth1:$eth1_http_port}"
ETH_2_KEYSTORE="${ETH_2_KEYSTORE:-validator_keys}"
ETH_API_KEY="${ETH_API_KEY:-abc123}"
ETH_DATA_ROOT="${ETH_DATA_ROOT:-$root/.data}"
ETH_DOMAINNAME="${ETH_DOMAINNAME:-}"
ETH_MAINNET="${ETH_MAINNET:-false}"

echo "Starting eth stack in env:"
echo "- ETH_1_CACHE=$ETH_1_CACHE"
echo "- ETH_1_DATADIR=$ETH_1_DATADIR"
echo "- ETH_1_LIGHT_SERVE=$ETH_1_LIGHT_SERVE"
echo "- ETH_2_DATADIR=$ETH_2_DATADIR"
echo "- ETH_2_ETH1_URL=$ETH_2_ETH1_URL"
echo "- ETH_2_KEYSTORE=$ETH_2_KEYSTORE"
echo "- ETH_API_KEY=$ETH_API_KEY"
echo "- ETH_DATA_ROOT=$ETH_DATA_ROOT"
echo "- ETH_DOMAINNAME=$ETH_DOMAINNAME"
echo "- ETH_MAINNET=$ETH_MAINNET"

########################################
## Configure internal vars

mkdir -pv "$ETH_DATA_ROOT/$ETH_1_DATADIR" "$ETH_DATA_ROOT/$ETH_2_DATADIR"

if [[ "$ETH_MAINNET" == "true" ]]
then
  eth1_network="mainnet"
  eth2_network="mainnet"
else
  eth1_network="goerli"
  eth2_network="pyrmont"
fi

proxy_image="${stack}_proxy:v$(grep proxy versions | awk -F '=' '{print $2}')"
geth_image="${stack}_geth:v$(grep "geth" versions | awk -F '=' '{print $2}')"
lighthouse_image="${stack}_lighthouse:v$(grep "lighthouse" versions | awk -F '=' '{print $2}')"

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

echo "Deploying $geth_image and $lighthouse_image"

logging="logging:
      driver: 'json-file'
      options:
          max-size: '100m'"

docker_compose=.docker-compose.yml
rm -rf $docker_compose
cat -> $docker_compose <<EOF
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
      ETH_1_HTTP: 'eth1:$eth1_http_port'
      ETH_1_WS: 'eth1:$eth1_ws_port'
      ETH_2_HTTP: 'beacon:$beacon_internal_port'
      ETH_API_KEY: '$ETH_API_KEY'
      ETH_DOMAINNAME: '$ETH_DOMAINNAME'
    $logging
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - 'certs:/etc/letsencrypt'

  eth1:
    image: $geth_image
    environment:
      ETH_1_CACHE: '$ETH_1_CACHE'
      ETH_1_DATADIR: '$ETH_1_DATADIR/$eth1_network'
      ETH_1_HTTP_PORT: '$eth1_http_port'
      ETH_1_LIGHT_SERVE: '$ETH_1_LIGHT_SERVE'
      ETH_1_NETWORK: '$eth1_network'
      ETH_1_WS_PORT: '$eth1_ws_port'
    $logging
    ports:
      - '30303:30303'
    volumes:
      - '$ETH_DATA_ROOT/$ETH_1_DATADIR:/root/$ETH_1_DATADIR'

  beacon:
    image: $lighthouse_image
    environment:
      ETH_2_DATADIR: '$ETH_2_DATADIR/$eth2_network'
      ETH_2_ETH1_URL: '$ETH_2_ETH1_URL'
      ETH_2_INTERNAL_PORT: '$beacon_internal_port'
      ETH_2_MODULE: 'beacon'
      ETH_2_NETWORK: '$eth2_network'
    $logging
    volumes:
      - '$ETH_DATA_ROOT/$ETH_2_DATADIR:/root/$ETH_2_DATADIR'

  validator:
    image: $lighthouse_image
    environment:
      ETH_2_BEACON_URL: 'http://beacon:$beacon_internal_port'
      ETH_2_DATADIR: '$ETH_2_DATADIR/$eth2_network'
      ETH_2_ETH1_URL: '$ETH_2_ETH1_URL'
      ETH_2_KEYSTORE: '$ETH_2_KEYSTORE'
      ETH_2_MODULE: 'validator'
      ETH_2_NETWORK: '$eth2_network'
      ETH_2_PASSWORD_FILE: '/run/secrets/$password_secret'
    $logging
    secrets:
      - '$password_secret'
    volumes:
      - '$ETH_DATA_ROOT/$ETH_2_DATADIR:/root/$ETH_2_DATADIR'
      - '$root/$ETH_2_KEYSTORE:/root/$ETH_2_KEYSTORE'

EOF

docker stack deploy --compose-file $docker_compose $stack
