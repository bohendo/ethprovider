#!/bin/bash

docker exec -it `docker container ls -f name=fullnode -q` sh -c "geth attach /root/geth.ipc"

