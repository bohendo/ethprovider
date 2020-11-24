#!/bin/sh

identity="${IDENTITY:-$(whoami)}"
data_dir="${DATA_DIR:-/data/geth}"

echo "Starting $(which geth) in env:"
echo "identity=$identity data_dir=$data_dir"

exec geth \
  --identity="$identity" \
  --datadir="$data_dir" \
  --cache=4096 \
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
