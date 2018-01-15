
cat - > /tmp/ethprovider/Dockerfile <<EOF
FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y bash sudo curl

RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh

ENTRYPOINT ["/usr/bin/parity"]

CMD [ "--identity=bohendo", "--base-path=/root/eth", "--ipc-path=/tmp/ipc/eth.ipc", "--auto-update=all", "--no-serve-light" ]
EOF

mkdir -p /tmp/ethprovider

docker build -f /tmp/ethprovider/Dockerfile -t `whoami`/ethprovider:latest -t ethprovider:latest /tmp/ethprovider

docker push `whoami`/ethprovider:latest

rm /tmp/ethprovider/Dockerfile

