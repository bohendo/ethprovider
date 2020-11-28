FROM messense/rust-musl-cross:x86_64-musl
WORKDIR /root
ENV HOME /root
ENV RUST_BACKTRACE 1
ARG VERSION=master

# install build tools, download source code, and build
#RUN apk add --no-cache build-base cmake eudev-dev linux-headers perl
#RUN apk add openssl-dev
RUN rustup update beta && rustup target add --toolchain beta x86_64-unknown-linux-musl
RUN git clone https://github.com/sigp/lighthouse.git /lighthouse
RUN apt-get install curl
RUN curl -s https://cmake.org/files/v3.18.5/cmake-3.18.5.Linux-x86_64.tar.gz
RUN (cd /tmp && ls -l && tar -xzvf cmake.tar.gz && ls -l)
#RUN apt-get update && apt-get install cmake

RUN cd /lighthouse && git checkout v$VERSION && make

FROM alpine:3.12
WORKDIR /root
ENV HOME /root

#COPY --from=builder / /usr/local/bin/
COPY entry.sh entry.sh

#EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["sh", "entry.sh"]
