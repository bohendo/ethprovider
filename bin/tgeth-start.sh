#!/bin/bash

log=$HOME/tgeth.log
ipc=$HOME/tgeth.ipc

# Setup a convenient error handler
function err { >&2 echo "Error: $1"; exit 1; }

# Don't start tgeth if it's already started
[[ -e "$ipc" ]] && err "tgeth is already running"

# Get our public ip address
publicip=`ifconfig eth0 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

# Add a division & timestamp in our tgeth log
echo "========== `date`" >> $log

# Start tgeth w rpc enabled
tgeth --cache=512 --ipcpath=$ipc                               \
  --ws --wsaddr=$publicip --wsport=8546 --wsorigins="*"        \
  --rpc --rpcaddr=$publicip --rpcport=8545 --rpccorsdomain="*" \
  2>> $log &

