#!/bin/sh

identity="${IDENTITY:-$(whoami)}"
data_dir="${DATA_DIR:-/data/geth}"

echo "Starting $(which geth) in env:"
echo "identity=$identity data_dir=$data_dir"

exec geth \
  --datadir="$data_dir" \
  --identity="$identity" \
  --nousb \
  --syncmode=fast \
  --light.serve=50 \
  --cache=4096 \
  --ipcdisable \
  --http \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=eth \
  --http.corsdomain=* \
  --http.vhosts=* \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.api=eth \
  --ws.origins=*
