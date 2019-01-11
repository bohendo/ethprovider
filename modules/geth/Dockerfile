FROM ethereum/client-go:v1.8.13 as base

FROM alpine:3.8

COPY --from=base /usr/local/bin/geth /usr/local/bin

RUN apk add --no-cache ca-certificates && mkdir /root/eth && mkdir /tmp/ipc

ENTRYPOINT ["/usr/local/bin/geth"]

CMD [ \
  "--identity=$me", \
  "--datadir=$data_dir", \
  "--lightserv=50", \
  "--nousb", \
  "--cache=$cache", \
  "--rpc", \
  "--rpcaddr=0.0.0.0", \
  "--rpcport=$http_port", \
  "--rpccorsdomain=*", \
  "--rpcvhosts=*", \
  "--ws", \
  "--wsaddr=0.0.0.0", \
  "--wsport=$ws_port", \
  "--wsapi=safe", \
  "--wsorigins=*", \
  "--ipcdisable", \
  "--shh" \
]
