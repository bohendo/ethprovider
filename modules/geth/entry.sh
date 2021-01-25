#!/bin/bash

ETH_1_CACHE="${ETH_1_CACHE:-2048}"
ETH_1_CLIENT="${ETH_1_CLIENT:-geth}"
ETH_1_NETWORK="${ETH_1_NETWORK:-goerli}"
ETH_1_DATADIR="${ETH_1_DATADIR:-$ETH_1_CLIENT/$ETH_1_NETWORK}"

echo "Starting Geth in env:"
echo "- ETH_1_CACHE=$ETH_1_CACHE"
echo "- ETH_1_CLIENT=$ETH_1_CLIENT"
echo "- ETH_1_NETWORK=$ETH_1_NETWORK"
echo "- ETH_1_DATADIR=$ETH_1_DATADIR"

if [[ "$ETH_1_NETWORK" == "mainnet" ]]
then network_flag=""
else network_flag="--$ETH_1_NETWORK"
fi

exec geth "$network_flag" \
  --cache="$ETH_1_CACHE" \
  --datadir="$ETH_1_DATADIR" \
  --http \
  --http.addr=0.0.0.0 \
  --http.api=eth,net \
  --http.corsdomain=* \
  --http.port=8545 \
  --http.vhosts=* \
  --ipcdisable \
  --light.serve=50 \
  --nousb \
  --syncmode=fast \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.api=eth,net \
  --ws.origins=* \
  --ws.port=8546 \
  "$@"
