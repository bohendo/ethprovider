FROM ubuntu:16.04
RUN apt-get update -y && apt-get install -y bash sudo curl
RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh # 2.0.1
ENTRYPOINT ["/usr/bin/parity"]
CMD [ \
  "--identity=$me", \
  "--base-path=$data_dir", \
  "--auto-update=all", \
  "--cache-size=$cache", \
  "--no-secretstore", \
  "--no-hardware-wallets", \
  "--jsonrpc-port=$http_port", \
  "--jsonrpc-interface=all", \
  "--jsonrpc-apis=safe", \
  "--jsonrpc-hosts=all", \
  "--jsonrpc-cors=all", \
  "--ws-port=$ws_port", \
  "--ws-interface=all", \
  "--ws-apis=safe", \
  "--ws-origins=all", \
  "--ws-hosts=all", \
  "--no-ipc", \
  "--whisper", \
  "--whisper-pool-size=128" \
]
