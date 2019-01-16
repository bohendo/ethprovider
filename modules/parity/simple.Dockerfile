FROM parity/parity:v2.2.7
USER root
WORKDIR /root
ENV HOME /root

RUN cp /home/parity/bin/parity /usr/local/bin/parity
COPY entry.sh entry.sh

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["sh", "entry.sh"]
