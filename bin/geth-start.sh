#!/bin/bash

privateip=`ifconfig eth1 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

echo "========== `date`" >> $HOME/geth.log

/usr/bin/geth --identity bonet \
  --rpc --rpcaddr $privateip --rpccorsdomain "https://bohendo.com,https://bohenderson.com" \
  2>> $HOME/geth.log &

