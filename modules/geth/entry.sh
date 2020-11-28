#!/bin/sh

exec geth \
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
