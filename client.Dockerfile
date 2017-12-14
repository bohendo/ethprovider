FROM ethereum/client-go:stable as base

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=base /usr/local/bin/geth /usr/local/bin

COPY ./build/ck.bundle.js /root/ck.bundle.js
WORKDIR /root

ENTRYPOINT ["/usr/local/bin/geth"]
CMD [ "attach", "--preload=/root/ck.bundle.js", "/tmp/ipc/geth.ipc" ]
