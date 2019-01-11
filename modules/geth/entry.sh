#!/bin/sh

name="$NAME"; [ -n "$name" ] || name="`whoami`"
data_dir="$DATA_DIR"; [ -n "$data_dir" ] || data_dir="/root/eth"
cache="$CACHE"; [ -n "$cache" ] || cache="2048"

echo "Starting `which geth` in env:"
echo "name=$name data_dir=$data_dir cache=$cache"

exec geth \
  --identity=$name \
  --datadir=$data_dir \
  --cache=$cache \
  --lightserv=50 \
  --nousb \
  --ipcdisable \
  --rpc \
  --rpcaddr=0.0.0.0 \
  --rpcport=8545 \
  --rpcapi=safe \
  --rpccorsdomain=* \
  --rpcvhosts=* \
  --ws \
  --wsaddr=0.0.0.0 \
  --wsport=8546 \
  --wsapi=safe \
  --wsorigins=* \
  --shh
