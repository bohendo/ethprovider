v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username

mkdir -p /tmp/localnode

cat - > /tmp/localnode/Dockerfile <<EOF
FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y bash sudo curl

RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh

EXPOSE 8545

ENTRYPOINT ["/usr/bin/parity"]
CMD [ \
  "--auto-update=all", \
  "--cache-size=1024", \
  "--light", \
  "--no-ui", \
  "--jsonrpc-interface=local", \
  "--jsonrpc-apis=safe,personal", \
  "--no-ws", \
  "--ipc-path=/tmp/ipc/eth.ipc", \
  "--ipc-apis=safe,personal", \
  "--identity=$me" \
]
EOF

docker build -f /tmp/localnode/Dockerfile -t $me/localnode:$v -t localnode:$v /tmp/localnode

docker push $me/localnode:$v

rm /tmp/localnode/Dockerfile

