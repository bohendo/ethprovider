FROM alpine:3.8 as builder

# install build tools
RUN apk add --no-cache --virtual .build-deps bash gcc go linux-headers make musl-dev openssl

RUN git clone https://github.com/ethereum/go-ethereum.git /go-ethereum
WORKDIR /go-ethereum
RUN make geth

FROM alpine:3.8
WORKDIR /root
ENV HOME /root

RUN apk add --update --no-cache ca-certificates

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/
COPY entry.sh entry.sh

EXPOSE 8545 8546 30303 30303/udp

ENTRYPOINT ["sh", "entry.sh"]
