#!/bin/bash

log=$HOME/geth.log
ipc=$HOME/geth.ipc
dir=$HOME/.ethereum

# Setup a convenient error handler
function err { >&2 echo "Error: $1"; exit 1; }

# Don't start geth if it's already started
[[ -e "$ipc" ]] && err "geth is already running"

# Get our internal ip address
publicip=`ifconfig eth0 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`
privateip=`ifconfig eth1 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

# Add a division & timestamp in our geth log
echo "========== `date`" >> $log

# Start geth w rpc enabled
geth \
  --port=30303 \
  --identity=bonet \
  --datadir="$dir" \
  --ipcpath="$ipc" \
  --ws \
  --wsaddr=$publicip \
  --wsport=25727 \
  --wsapi="eth,web3" \
  --wsorigins="*" \
  2>> "$log" &

