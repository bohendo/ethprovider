ARG VERSION=latest
FROM gcr.io/prysmaticlabs/prysm/beacon-chain:$VERSION
WORKDIR /root
ENV HOME /root
COPY beacon.sh entry.sh
EXPOSE 4000 13000 12000
ENTRYPOINT ["bash", "entry.sh"]
