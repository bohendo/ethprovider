v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username

mkdir -p /tmp/localnode

cat - > /tmp/localnode/Dockerfile <<EOF
FROM ethereum/client-go:v1.8.0 as base
FROM alpine:latest
COPY --from=base /usr/local/bin/geth /usr/local/bin

RUN apk add --no-cache ca-certificates

RUN mkdir /root/eth && mkdir /tmp/ipc

ENTRYPOINT ["/usr/local/bin/geth"]
CMD [\
  "--datadir=/root/eth", \
  "--cache=1024", \
  "--ipcpath=/tmp/ipc/geth.ipc", \
  "--identity=$me"  \
]
EOF

docker build -f /tmp/localnode/Dockerfile -t $me/localnode:$v -t localnode:$v /tmp/localnode

docker push $me/localnode:$v

rm /tmp/localnode/Dockerfile

