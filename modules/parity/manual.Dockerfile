FROM alpine:edge
WORKDIR /root
ENV HOME /root
ENV RUST_BACKTRACE 1
ENV VERSION v2.2.6

# install build tools, download source code, and build
RUN apk add --no-cache --virtual build-tools \
    build-base cargo cmake eudev-dev git linux-headers perl rust \
 && git clone --progress https://github.com/paritytech/parity-ethereum.git /parity \
 && cd /parity \
 && git checkout $VERSION \
 && cargo build --release --target x86_64-alpine-linux-musl --verbose \
 && strip target/x86_64-alpine-linux-musl/release/parity \
 && cp target/x86_64-alpine-linux-musl/release/parity /usr/local/bin/ \
 && cd $HOME \
 && rm -rf /parity \
 && apk del build-tools \
 && apk add --no-cache ca-certificates eudev libgcc libstdc++

COPY entry.sh entry.sh

EXPOSE 8545 8546 30303 30303/udp

ENTRYPOINT ["sh", "entry.sh"]
