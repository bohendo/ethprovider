FROM alpine:3.8 as builder
ENV RUST_BACKTRACE 1

RUN apk add --update --no-cache binutils cargo curl eudev-dev file g++ gcc git libusb-dev linux-headers make musl-dev openssl-dev pkgconfig rust
RUN rustc -vV && cargo -V && gcc -v && g++ -v 
RUN git clone --progress https://github.com/paritytech/parity-ethereum.git /parity
WORKDIR /parity
RUN git checkout v2.2.6
RUN ls
RUN cargo build --release --verbose
RUN ls /build/parity/target/release/parity && strip /build/parity/target/release/parity && file /build/parity/target/release/parity

FROM alpine:3.8
WORKDIR /root
ENV HOME /root

RUN apk add --update --no-cache bash ca-certificates

COPY --from=builder /build/parity/target/release/parity /usr/bin/parity
COPY entry.sh entry.sh

EXPOSE 8545 8546 30303 30303/udp

ENTRYPOINT ["bash", "entry.sh"]
