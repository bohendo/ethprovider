#!/bin/bash

ETH_2_BEACON_URL="${ETH_2_BEACON_URL:-http://beacon:5052}"
ETH_2_ETH1_URL="${ETH_2_ETH1_URL:-http://eth1:8545}"
ETH_2_MODULE="${ETH_2_MODULE:-beacon}"
ETH_2_NETWORK="${ETH_2_NETWORK:-mainnet}"

if [[ "$ETH_2_MODULE" == "beacon" ]]
then
  echo "Running Lighthouse Beacon"
  exec lighthouse --network "$ETH_2_NETWORK" beacon \
    --eth1-endpoints="$ETH_2_ETH1_URL" \
    --ws \
    --ws-address=0.0.0.0 \
    --ws-port=5053 \
    --http \
    --http-address=0.0.0.0 \
    --http-port=5052 \
    --http-allow-origin "*"

elif [[ "$ETH_2_MODULE" == "validator" ]]
then
  echo "Running Lighthouse Validator"
  exec lighthouse --network "$ETH_2_NETWORK" validator --beacon-node="$ETH_2_BEACON_URL"

fi
