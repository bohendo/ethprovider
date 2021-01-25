#!/bin/bash

ETH_2_BEACON_URL="${ETH_2_BEACON_URL:-http://beacon:5052}"
ETH_2_DATADIR="${ETH_2_DATADIR:-.eth2}"
ETH_2_ETH1_URL="${ETH_2_ETH1_URL:-http://eth1:8545}"
ETH_2_MODULE="${ETH_2_MODULE:-beacon}"
ETH_2_NETWORK="${ETH_2_NETWORK:-pyrmont}"
ETH_2_PASSWORD="${ETH_2_PASSWORD:-/run/secrets/password}"
ETH_KEYSTORE="${ETH_KEYSTORE:-$ETH_2_DATADIR/validator_keys}"

echo "Starting Prysm in env:"
echo "- ETH_2_BEACON_URL=$ETH_2_BEACON_URL"
echo "- ETH_2_DATADIR=$ETH_2_DATADIR"
echo "- ETH_2_ETH1_URL=$ETH_2_ETH1_URL"
echo "- ETH_2_MODULE=$ETH_2_MODULE"
echo "- ETH_2_NETWORK=$ETH_2_NETWORK"
echo "- ETH_2_PASSWORD=$ETH_2_PASSWORD"
echo "- ETH_KEYSTORE=$ETH_KEYSTORE"

function waitfor {
  no_proto=${1#*://}
  hostname=${no_proto%/*}
  echo "waiting for $hostname to wake up..."
  wait-for -q -t 60 "$hostname" 2>&1 | sed '/nc: bad address/d'
}

if [[ "$ETH_2_MODULE" == "beacon" ]]
then
  waitfor "$ETH_2_ETH1_URL"
  echo "Running Prysm Beacon"
  beacon \
    "--$ETH_2_NETWORK" \
    --accept-terms-of-use \
    --datadir="$ETH_2_DATADIR" \
    --http-web3provider="$ETH_2_ETH1_URL"

elif [[ "$ETH_2_MODULE" == "validator" ]]
then
  waitfor "$ETH_2_BEACON_URL"
  echo "Running Prysm Validator"
  validator \
    "--$ETH_2_NETWORK" \
    --accept-terms-of-use \
    --beacon-rpc-provider="$ETH_2_BEACON_URL" \
    --datadir="$ETH_2_DATADIR" \
    --wallet-dir="$ETH_KEYSTORE" \
    --wallet-password-file="$ETH_2_PASSWORD"

else
  echo "Unknown Prysm module: $ETH_2_MODULE"
  exit 1

fi
