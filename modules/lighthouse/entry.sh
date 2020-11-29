#!/bin/bash

ETH_2_NETWORK="${ETH_2_NETWORK:-mainnet}"
ETH_2_MODULE="${ETH_2_MODULE:-beacon}"

defs=validator_definitions.yml
if [[ -f "$defs" ]]
then cp -f "$defs" "/root/.lighthouse/$ETH_2_NETWORK/$defs"
fi

if [[ "$ETH_2_MODULE" == "beacon" ]]
then
  echo "Running Lighthouse Beacon"
  exec lighthouse --network "$ETH_2_NETWORK" beacon \
    --http \
    --http-address=0.0.0.0

elif [[ "$ETH_2_MODULE" == "validator" ]]
then
  echo "Running Lighthouse Validator"
  exec lighthouse --network "$ETH_2_NETWORK" validator

fi
