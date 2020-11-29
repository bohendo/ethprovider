ARG VERSION=latest
FROM sigp/lighthouse:$VERSION
WORKDIR /root
ENV HOME /root
COPY entry.sh entry.sh
EXPOSE 9000 5052
ENTRYPOINT ["bash", "entry.sh"]
