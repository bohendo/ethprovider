ARG VERSION=latest
FROM sigp/lighthouse:$VERSION as lighthouse_source
RUN which lighthouse
FROM debian:10.7-slim
WORKDIR /root
ENV HOME /root
COPY --from=lighthouse_source /usr/local/bin/lighthouse /bin/lighthouse
RUN apt-get update -y
RUN apt-get install -y curl
RUN curl https://raw.githubusercontent.com/vishnubob/wait-for-it/ed77b63706ea721766a62ff22d3a251d8b4a6a30/wait-for-it.sh > /bin/wait-for && chmod +x /bin/wait-for
COPY entry.sh entry.sh
EXPOSE 9000 5052
ENTRYPOINT ["bash", "entry.sh"]
