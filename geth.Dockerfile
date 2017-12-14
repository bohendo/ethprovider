FROM ethereum/client-go:stable as base

FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=base /usr/local/bin/geth /usr/local/bin

COPY ./build/ck.bundle.js /root/ck.bundle.js

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/geth"]

CMD [ "--identity=bonet", "--datadir=/root/.ethereum", "--ipcpath=/root/geth.ipc", "--keystore=/run/secrets" ]

