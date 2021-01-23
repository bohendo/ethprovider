ARG VERSION=latest
FROM gcr.io/prysmaticlabs/prysm/validator:$VERSION
WORKDIR /root
ENV HOME /root
COPY validator.sh entry.sh
EXPOSE 4000 13000 12000
ENTRYPOINT ["bash", "entry.sh"]

