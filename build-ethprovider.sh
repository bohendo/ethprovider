
cat - > /tmp/ethprovider.Dockerfile <<EOF
FROM ethereum/client-go:stable as base

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=base /usr/local/bin/geth /usr/local/bin

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/geth"]
CMD [ "--identity=bonet", "--datadir=/root/.ethereum", "--ipcpath=/tmp/ipc/geth.ipc", "--keystore=/run/secrets", "--cache=1024" ]
EOF

docker build -f /tmp/ethprovider.Dockerfile -t `whoami`/ethprovider:latest -t ethprovider:latest .

docker push `whoami`/ethprovider:latest

rm /tmp/ethprovider.Dockerfile

