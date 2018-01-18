
v=latest # tweak to deploy a specific version number

mkdir -p /tmp/ethprovider

cat - > /tmp/ethprovider/Dockerfile <<EOF
FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y bash sudo curl

RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh

ENTRYPOINT ["/usr/bin/parity"]

CMD [ \
  "--identity=bohendo", \
  "--base-path=/root/eth", \
  "--ipc-path=/tmp/ipc/eth.ipc", \
  "--auto-update=all", \
  "--cache-size=8192" \
]
EOF

docker build -f /tmp/ethprovider/Dockerfile -t `whoami`/ethprovider:$v -t ethprovider:$v /tmp/ethprovider

docker push `whoami`/ethprovider:$v

rm /tmp/ethprovider/Dockerfile

