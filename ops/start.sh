#!/bin/bash
set -e

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

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

ETH_1_CACHE="${ETH_1_CACHE:-2048}"
ETH_1_DATADIR="${ETH_1_DATADIR:-geth}"
ETH_1_NETWORK="${ETH_1_NETWORK:-goerli}"
ETH_2_DATADIR="${ETH_2_DATADIR:-lighthouse}"
ETH_2_KEYSTORE="${ETH_2_DATADIR:-validator_keys}"
ETH_2_ETH1_URL="${ETH_2_ETH1_URL:-http://eth1:8545}"
ETH_2_INTERNAL_PORT="${ETH_2_INTERNAL_PORT:-5025}"
ETH_2_NETWORK="${ETH_2_NETWORK:-pyrmont}"
ETH_API_KEY="${ETH_API_KEY:-abc123}"
ETH_DATA_ROOT="${ETH_DATA_ROOT:-.data}"
ETH_DOMAINNAME="${ETH_DOMAINNAME:-}"

echo "Starting eth stack in env:"
echo "- ETH_1_CACHE=$ETH_1_CACHE"
echo "- ETH_1_DATADIR=$ETH_1_DATADIR"
echo "- ETH_1_NETWORK=$ETH_1_NETWORK"
echo "- ETH_2_DATADIR=$ETH_2_DATADIR"
echo "- ETH_2_ETH1_URL=$ETH_2_ETH1_URL"
echo "- ETH_2_INTERNAL_PORT=$ETH_2_INTERNAL_PORT"
echo "- ETH_2_KEYSTORE=$ETH_2_KEYSTORE"
echo "- ETH_2_NETWORK=$ETH_2_NETWORK"
echo "- ETH_API_KEY=$ETH_API_KEY"
echo "- ETH_DATA_ROOT=$ETH_DATA_ROOT"
echo "- ETH_DOMAINNAME=$ETH_DOMAINNAME"

########################################
## Configure internal vars

data="$root/$ETH_DATA_ROOT"
mkdir -p "$data/$ETH_1_DATADIR" "$data/$ETH_2_DATADIR"

proxy_image="${stack}_proxy:v$(grep proxy versions | awk -F '=' '{print $2}')"
geth_image="${stack}_geth:v$(grep "geth" versions | awk -F '=' '{print $2}')"
lighthouse_image="${stack}_lighthouse:v$(grep "lighthouse" versions | awk -F '=' '{print $2}')"
# prysm_image="${stack}_prysm:v$(grep "prysm" versions | awk -F '=' '{print $2}')"

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

echo "Deploying images $proxy_image and $geth_image among others"

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
      ETH_1_HTTP: 'eth1:8545'
      ETH_1_WS: 'eth1:8546'
      ETH_2_HTTP: 'beacon:$ETH_2_INTERNAL_PORT'
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
      ETH_1_DATADIR: '$ETH_1_DATADIR/$ETH_1_NETWORK'
      ETH_1_NETWORK: '$ETH_1_NETWORK'
    $logging
    ports:
      - '30303:30303'
    volumes:
      - '$data/$ETH_1_DATADIR:/root/$ETH_1_DATADIR'

  beacon:
    image: $lighthouse_image
    environment:
      ETH_2_DATADIR: '$ETH_2_DATADIR'
      ETH_2_ETH1_URL: '$ETH_2_ETH1_URL'
      ETH_2_MODULE: 'beacon'
      ETH_2_NETWORK: '$ETH_2_NETWORK'
      ETH_2_INTERNAL_PORT: '$ETH_2_INTERNAL_PORT'
    $logging
    volumes:
      - '$data/$ETH_2_DATADIR:/root/$ETH_2_DATADIR'

  validator:
    image: $lighthouse_image
    environment:
      ETH_2_BEACON_URL: 'http://beacon:$ETH_2_INTERNAL_PORT'
      ETH_2_DATADIR: '$ETH_2_DATADIR'
      ETH_2_KEYSTORE: '$ETH_2_KEYSTORE'
      ETH_2_MODULE: 'validator'
      ETH_2_NETWORK: '$ETH_2_NETWORK'
      ETH_2_PASSWORD_FILE: '/run/secrets/$password_secret'
    $logging
    secrets:
      - '$password_secret'
    volumes:
      - '$data/$ETH_2_DATADIR:/root/$ETH_2_DATADIR'
      - '$root/$ETH_2_KEYSTORE:/root/$ETH_2_KEYSTORE'

EOF

docker stack deploy --compose-file $docker_compose $stack
