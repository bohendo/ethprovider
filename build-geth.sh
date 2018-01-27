
v=latest # tweak to deploy a specific version number

me=`whoami` # your docker.io username

mkdir -p /tmp/ethprovider

cat - > /tmp/ethprovider/Dockerfile <<EOF
FROM ethereum/client-go:stable as base

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=base /usr/local/bin/geth /usr/local/bin

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/geth"]
CMD [ \
  "--datadir=/root/eth", \
  "--cache=8192" \
  "--ipcpath=/tmp/ipc/eth.ipc", \
  "--identity=$me", \
]
EOF

docker build -f /tmp/ethprovider/Dockerfile -t $me/ethprovider:$v -t ethprovider:$v /tmp/ethprovider

docker push $me/ethprovider:$v

rm /tmp/ethprovider/Dockerfile

