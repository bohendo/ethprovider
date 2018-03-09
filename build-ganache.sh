#!/bin/bash

me=`whoami` # your docker.io username
v=latest # tweak to deploy a specific version number
mkdir -p /tmp/ganache

cat - > /tmp/ganache/Dockerfile <<EOF
FROM node:9.7-alpine

RUN apk --no-cache add git curl

RUN npm install -g ganache-cli@beta

VOLUME /root/ganache

ENTRYPOINT ["ganache-cli"]
CMD [\
  "--db /root/ganache", \
  "--port=8545", \
  "--networkId=5777", \
  "--mnemonic=candy maple cake sugar pudding cream honey rich smooth crumble sweet treat" \
]
EOF

docker build -f /tmp/ganache/Dockerfile -t $me/ganache:$v -t ganache:$v /tmp/ganache
docker push $me/ganache:$v
rm /tmp/ganache/Dockerfile
