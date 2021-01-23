#!/bin/bash

ETH_2_BEACON_URL="${ETH_2_BEACON_URL:-http://beacon:5052}"
ETH_2_ETH1_URL="${ETH_2_ETH1_URL:-http://eth1:8545}"
ETH_2_MODULE="${ETH_2_MODULE:-beacon}"
ETH_2_NETWORK="${ETH_2_NETWORK:-mainnet}"

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
  exec beacon \
    --network "$ETH_2_NETWORK" \
    --eth1-endpoints="$ETH_2_ETH1_URL" \
    --http \
    --http-address=0.0.0.0 \
    --http-port=5052 \
    --http-allow-origin "*"

elif [[ "$ETH_2_MODULE" == "validator" ]]
then
  waitfor "$ETH_2_BEACON_URL"
  echo "Running Prysm Validator"
  exec validator --network "$ETH_2_NETWORK" --beacon-node="$ETH_2_BEACON_URL"

fi

