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
ETH_API_KEY="${ETH_API_KEY:-abc123}"
ETH_DOMAINNAME="${ETH_DOMAINNAME:-localhost}"
ETH_IDENTITY="${ETH_IDENTITY:-$(whoami)}"
ETH_VALIDATOR_PUBKEY="${ETH_VALIDATOR_PUBKEY:-}"
ETH_VALIDATOR_DEFINITIONS="${ETH_VALIDATOR_DEFINITIONS:-$(pwd)/.keystore.json}"

mkdir -p "$ETH_1_DATADIR" "$ETH_2_DATADIR"
touch "$ETH_VALIDATOR_DEFINITIONS"

proxy_image="${stack}_proxy:$(grep proxy versions | awk -F '=' '{print $2}')"
eth1_image="${stack}_${ETH_1_CLIENT}:$(grep "$ETH_1_CLIENT" versions | awk -F '=' '{print $2}')"
eth2_image="${stack}_${ETH_2_CLIENT}:$(grep "$ETH_2_CLIENT" versions | awk -F '=' '{print $2}')"

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
## Setup validator definitions

if [[ ! -f "validator_definitions.yml" ]]
then cp validator_definitions.example.yml validator_definitions.yml
fi

########################################
## Deploy

echo "Deploying images $proxy_image and $eth1_image"

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
      ETH_API_KEY: '$ETH_API_KEY'
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
    environment:
      ETH_VALIDATOR_PUBKEY: '$ETH_VALIDATOR_PUBKEY'
    logging:
      driver: 'json-file'
      options:
          max-size: '100m'
    ports:
      - '9000:9000'
    secrets:
      - '$password_secret'
    volumes:
      - '$ETH_2_DATADIR:/root/.lighthouse'
      - '$ETH_VALIDATOR_DEFINITIONS:/root/validator-definitions.yml'

EOF

docker stack deploy --compose-file docker-compose.yml $stack
