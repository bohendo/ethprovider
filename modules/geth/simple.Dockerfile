FROM ethereum/client-go:v1.8.20 as base
WORKDIR /root
ENV HOME /root

RUN apk add --update --no-cache bash ca-certificates

COPY entry.sh entry.sh

EXPOSE 8545 8546 30303 30303/udp

ENTRYPOINT ["bash", "entry.sh"]
