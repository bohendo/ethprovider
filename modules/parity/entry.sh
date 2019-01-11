#!/bin/bash

echo "Starting `which parity` in env:"
env

name=NAME; [[ -n "$name" ]] || name=bohendo
data_dir=DATA_DIR; [[ -n "$data_dir" ]] || data_dir=/root/eth
cache=CACHE; [[ -n "$cache" ]] || cache=

parity \
  --identity=$name \
  --base-path=$data_dir \
  --cache-size=$cache \
  --auto-update=all \
  --no-secretstore \
  --no-hardware-wallets \
  --no-ipc \
  --jsonrpc-port=8545 \
  --jsonrpc-interface=all \
  --jsonrpc-apis=safe \
  --jsonrpc-hosts=all \
  --jsonrpc-cors=all \
  --ws-port=8546 \
  --ws-interface=all \
  --ws-apis=safe \
  --ws-origins=all \
  --ws-hosts=all \
  --whisper \
  --whisper-pool-size=128
