#!/bin/bash

# Setup a convenient error handler
function err { >&2 echo "Error: $1"; exit 1; }

# Don't start tgeth if it's already started
[[ -e "$HOME/tgeth.ipc" ]] && err "tgeth is already running"

# Get our public ip address
publicip=`ifconfig eth0 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

# Add a division & timestamp in our tgeth log
echo "========== `date`" >> $HOME/tgeth.log

# Start tgeth w rpc enabled
tgeth --rpc --rpcaddr $publicip --rpcport 8545 --rpccorsdomain "*" --ipcpath $HOME/tgeth.ipc 2>> $HOME/tgeth.log &

