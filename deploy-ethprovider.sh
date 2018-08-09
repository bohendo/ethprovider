#!/bin/bash
set -e

## Config

provider="parity"

me=`whoami`
name="ethprovider"
cache="4096"
http_port="8545"
ws_port="8546"

## Build Docker Image

image="$me/ethprovider_$provider:latest"
tmp="/tmp/ethprovider"
mkdir -p $tmp

cat - > $tmp/parity.Dockerfile <<EOF
FROM ubuntu:16.04
RUN apt-get update -y && apt-get install -y bash sudo curl
RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh
RUN /usr/bin/parity --version // 2.0.1
ENTRYPOINT ["/usr/bin/parity"]
EOF

cat - > $tmp/geth.Dockerfile <<EOF
FROM ethereum/client-go:v1.8.13 as base
FROM alpine:latest
COPY --from=base /usr/local/bin/geth /usr/local/bin
RUN apk add --no-cache ca-certificates && mkdir /root/eth && mkdir /tmp/ipc
RUN /usr/local/bin/geth --version // 1.8.13
ENTRYPOINT ["/usr/local/bin/geth"]
EOF

docker build -f $tmp/$provider.Dockerfile -t $image $tmp/
rm -rf $tmp

## Set docker & provider options according to config

data_dir="/root/eth"

docker_options='
    --name="'"$name"'" \
    --mode="global" \
    --mount="'"type=volume,source=${provider}_data,destination=$data_dir"'" \
    --publish="'"$http_port:$http_port"'" \
    --publish="'"$ws_port:$ws_port"'" \
    --publish="30303:30303" \
    --detach \
'

if [[ "$provider" = "parity" ]]
then
    provider_options='
    --identity="'"$me"'"
    --base-path="'"$data_dir"'"
    --auto-update="all"
    --cache-size="'"$cache"'"
    --no-secret-store
    --no-hardware-wallets
    --no-ui
    --jsonrpc-port="'"$http_port"'"
    --jsonrpc-interface="all"
    --jsonrpc-apis="safe"
    --jsonrpc-hosts="all"
    --jsonrpc-cors="all"
    --ws-port="'"$ws_port"'"
    --ws-interface="all"
    --ws-apis="safe"
    --ws-origins="all"
    --ws-hosts="all"
    --no-ipc
    --whisper
    --whisper-pool-size=128
    '

elif [[ "$provider" == "geth" ]]
then
    provider_options='
    --identity "'"$me"'"
    --datadir "'"$data_dir"'"
    --lightserv "50"
    --no-usb
    --cache "'"$cache"'"
    --rpc
    --rpcaddr "0.0.0.0"
    --rpcport "'"$http_port"'"
    --rpcapi "safe"
    --rpccorsdomain "*"
    --rpcvhosts "*"
    --ws
    --wsaddr "0.0.0.0"
    --wsport "'"$ws_port"'"
    --wsapi "safe"
    --wsorigins "*"
    --ipcdisable
    --shh
    '
fi

docker service create $docker_options $image $provider_options
docker service logs -f $name
