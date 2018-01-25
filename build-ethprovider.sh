v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username

mkdir -p /tmp/ethprovider

cat - > /tmp/ethprovider/Dockerfile <<EOF
FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y bash sudo curl

RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh

ENTRYPOINT ["/usr/bin/parity"]
CMD [ \
  "--base-path=/root/eth", \
  "--auto-update=all", \
  "--cache-size=8192", \
  "--no-ui", \
  "--no-jsonrpc", \
  "--no-ws", \
  "--ipc-path=/tmp/ipc/eth.ipc", \
  "--ipc-api=safe,personal", \
  "--identity=$me" \
]
EOF

docker build -f /tmp/ethprovider/Dockerfile -t $me/ethprovider:$v -t ethprovider:$v /tmp/ethprovider

docker push $me/ethprovider:$v

rm /tmp/ethprovider/Dockerfile

