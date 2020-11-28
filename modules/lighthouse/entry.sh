#!/bin/bash

lighthouse \
  --network mainnet \
  account \
  validator \
  import \
    --keystore keystore.json \
    --stdin-inputs \
    <<<"$(cat /run/secrets/validator_keystore_password)"

exec lighthouse beacon --http --http-address=0.0.0.0
