#!/bin/sh

exec geth \
  --nousb \
  --syncmode=fast \
  --light.serve=50 \
  --cache=2048 \
  --ipcdisable \
  --http \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=eth,net \
  --http.corsdomain=* \
  --http.vhosts=* \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.api=eth,net \
  --ws.origins=* \
  "$@"
