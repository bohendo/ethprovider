#!/bin/bash

# Setup a convenient error handler
function err { >&2 echo "Error: $1"; exit 1; }

# Don't start geth if it's already started
[[ -e "$HOME/geth.ipc" ]] && err "geth is already running"

# Get our internal ip address
privateip=`ifconfig eth1 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

# Add a division & timestamp in our geth log
echo "========== `date`" >> $HOME/geth.log

# Start geth w rpc enabled
geth --identity bonet --rpc --rpcaddr $privateip --rpcport 3993 --ipcpath $HOME/geth.ipc 2>> $HOME/geth.log &

