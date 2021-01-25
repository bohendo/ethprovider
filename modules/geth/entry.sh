#!/bin/bash

ETH_1_LIGHT_SERVE="${ETH_1_LIGHT_SERVE:-20}"
ETH_1_CACHE="${ETH_1_CACHE:-2048}"
ETH_1_NETWORK="${ETH_1_NETWORK:-goerli}"
ETH_1_HTTP_PORT="${ETH_1_HTTP_PORT:-8545}"
ETH_1_WS_PORT="${ETH_1_WS_PORT:-8546}"

ETH_1_DATADIR="${ETH_1_DATADIR:-geth/$ETH_1_NETWORK}"

echo "Starting Geth in env:"
echo "- ETH_1_CACHE=$ETH_1_CACHE"
echo "- ETH_1_NETWORK=$ETH_1_NETWORK"
echo "- ETH_1_DATADIR=$ETH_1_DATADIR"
echo "- ETH_1_HTTP_PORT=$ETH_1_HTTP_PORT"
echo "- ETH_1_WS_PORT=$ETH_1_WS_PORT"

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
  --http.port="$ETH_1_HTTP_PORT" \
  --http.vhosts=* \
  --ipcdisable \
  --light.serve="$ETH_1_LIGHT_SERVE" \
  --nousb \
  --syncmode=fast \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.api=eth,net \
  --ws.origins=* \
  --ws.port="$ETH_1_WS_PORT" \
  "$@"
