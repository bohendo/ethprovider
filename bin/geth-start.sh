#!/bin/bash

privateip=`ifconfig eth1 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

geth --identity bonet --rpc --rpcaddr $privateip --rpccorsdomain "https://bohendo.com,https://bohenderson.com"

