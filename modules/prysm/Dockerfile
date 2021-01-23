ARG VERSION=latest
FROM gcr.io/prysmaticlabs/prysm/validator:$VERSION as validator_source
FROM gcr.io/prysmaticlabs/prysm/beacon-chain:$VERSION as beacon_source
FROM debian:10.7-slim
WORKDIR /root
ENV HOME /root
COPY --from=beacon_source /app/beacon-chain/beacon-chain /bin/beacon
COPY --from=validator_source /app/validator/validator /bin/validator
COPY entry.sh entry.sh
EXPOSE 4000 13000 12000
ENTRYPOINT ["bash", "entry.sh"]
