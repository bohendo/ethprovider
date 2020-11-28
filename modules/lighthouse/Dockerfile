FROM alpine:edge as builder
WORKDIR /root
ENV HOME /root
ARG VERSION=master

# install build tools, download source code, and build
RUN apk add --no-cache --virtual build-tools \
    build-base cargo cmake eudev-dev git linux-headers perl rust

RUN git clone https://github.com/sigp/lighthouse.git lighthouse \
 && cd lighthouse \
 && git checkout v$VERSION

ENV RUST_BACKTRACE 1
RUN cd lighthouse && cargo build --release --target x86_64-alpine-linux-musl --verbose

FROM alpine:3.12
WORKDIR /root
ENV HOME /root

#COPY --from=builder / /usr/local/bin/
COPY entry.sh entry.sh

#EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["sh", "entry.sh"]
