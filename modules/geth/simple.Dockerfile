FROM ethereum/client-go:v1.8.22
USER root
WORKDIR /root
ENV HOME /root
COPY entry.sh entry.sh
EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["sh", "entry.sh"]
