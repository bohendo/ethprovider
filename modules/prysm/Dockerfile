ARG VERSION=latest
FROM gcr.io/prysmaticlabs/prysm/validator:$VERSION as validator_source
FROM gcr.io/prysmaticlabs/prysm/beacon-chain:$VERSION as beacon_source
FROM debian:10.7-slim
WORKDIR /root
ENV HOME /root
COPY --from=beacon_source /app/beacon-chain/beacon-chain /bin/beacon
COPY --from=validator_source /app/validator/validator /bin/validator
RUN apt-get update -y && apt-get install -y curl
RUN curl https://raw.githubusercontent.com/vishnubob/wait-for-it/ed77b63706ea721766a62ff22d3a251d8b4a6a30/wait-for-it.sh > /bin/wait-for && chmod +x /bin/wait-for
COPY entry.sh entry.sh
EXPOSE 4000 13000 12000
ENTRYPOINT ["bash", "entry.sh"]
