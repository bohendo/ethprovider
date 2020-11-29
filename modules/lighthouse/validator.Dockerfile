ARG VERSION=latest
FROM sigp/lighthouse:v$VERSION
WORKDIR /root
ENV HOME /root
COPY validator.entry.sh entry.sh
EXPOSE 9000 5052
ENTRYPOINT ["sh", "entry.sh"]
