FROM parity/parity:v2.2.6

COPY entry.sh entry.sh

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["sh", "entry.sh"]
