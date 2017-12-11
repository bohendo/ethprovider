#!/bin/bash

log=$HOME/tgeth.log
ipc=$HOME/tgeth.ipc
dir=$HOME/.bonet

# Setup a convenient error handler
function err { >&2 echo "Error: $1"; exit 1; }

# Don't start tgeth if it's already started
[[ -e "$ipc" ]] && err "tgeth is already running"

# Get our public ip address
publicip=`ifconfig eth0 | grep 'inet addr' | awk '{print $2;exit}' | sed 's/addr://'`

# Add a division & timestamp in our tgeth log
echo "========== `date`" >> $log

if [[ ! -d $dir/geth ]]
then
  echo "Inializing genesis block..."
  cat > /tmp/genesis.json <<EOF
{"config":{"chainId":3993,"homesteadBlock":1,"eip150Block":2,"eip150Hash":"0x0000000000000000000000000000000000000000000000000000000000000000","eip155Block":3,"eip158Block":3,"byzantiumBlock":4,"clique":{"period":15,"epoch":30000}},"nonce":"0x0","timestamp":"0x5a0ccf38","extraData":"0x0000000000000000000000000000000000000000000000000000000000000000dd8251bb8e7ba07dfcd9e1842cd9e3cdfc0399c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","gasLimit":"0x47b760","difficulty":"0x1","mixHash":"0x0000000000000000000000000000000000000000000000000000000000000000","coinbase":"0x0000000000000000000000000000000000000000","alloc":{"dd8251bb8e7ba07dfcd9e1842cd9e3cdfc0399c8":{"balance":"0x200000000000000000000000000000000000000000000000000000000000000"}},"number":"0x0","gasUsed":"0x0","parentHash":"0x0000000000000000000000000000000000000000000000000000000000000000"}
EOF
  geth --datadir=$dir init /tmp/genesis.json
fi

bootnode='6ca689137170d93a24478c1d075b1fdc6b21b1d02df2ea22da702cd49097a8ffa63e87250e1353a541fd2cd2f13cabdbaed31639f59b11d44c830e9eefa917cd'

label='bonet'

geth \
  --identity="$label" \
  --networkid=3993 \
  --datadir="$dir" \
  --port=40408 \
  --ethstats="$label:secret@stats.bohendo.net" \
  --bootnodes="enode://$bootnode@159.203.53.236:40404" \
  --cache=512 \
  --ipcpath="$ipc" \
  --ws \
  --wsaddr="$publicip" \
  --wsport=8546 \
  --wsorigins="*" \
  --wsapi="eth,net,web3,personal" \
  2>> "$log" &


