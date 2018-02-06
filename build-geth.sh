
v=latest # tweak to deploy a specific version number

me=`whoami` # your docker.io username

mkdir -p /tmp/geth

cat - > /tmp/geth/Dockerfile <<EOF
FROM ethereum/client-go:latest as base
FROM alpine:latest
COPY --from=base /usr/local/bin/geth /usr/local/bin

RUN apk add --no-cache ca-certificates

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/geth"]
CMD [ \
  "--datadir=/root/eth", \
  "--cache=8192" \
  "--ipcpath=/tmp/ipc/eth.ipc", \
  "--identity=$me", \
]
EOF

docker build -f /tmp/geth/Dockerfile -t $me/geth:$v -t geth:$v /tmp/geth

docker push $me/geth:$v

rm /tmp/geth/Dockerfile

