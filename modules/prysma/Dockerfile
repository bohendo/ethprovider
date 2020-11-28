FROM alpine:edge
WORKDIR /root
ENV HOME /root
ARG VERSION=master

RUN apk add ca-certificates cmake git make wget
RUN git clone https://github.com/prysmaticlabs/prysm
RUN apk add bazel --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN (cd prysm && bazel build //beacon-chain:beacon-chain)
RUN (cd prysm && bazel build //validator:validator)
