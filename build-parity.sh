#!/bin/bash

v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username

mkdir -p /tmp/parity

cat - > /tmp/parity/Dockerfile <<EOF
FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y bash sudo curl

RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh

ENTRYPOINT ["/usr/bin/parity"]
CMD [\
  "--base-path=/root/eth", \
  "--auto-update=all", \
  "--cache-size=4096", \
  "--no-ui", \
  "--no-jsonrpc", \
  "--no-ws", \
  "--ipc-path=/tmp/ipc/parity.ipc", \
  "--ipc-apis=safe,personal", \
  "--identity=$me"  \
]
EOF

docker build -f /tmp/parity/Dockerfile -t $me/parity:$v -t parity:$v /tmp/parity

docker push $me/parity:$v

rm /tmp/parity/Dockerfile

