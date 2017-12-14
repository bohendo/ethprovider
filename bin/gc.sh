#!/bin/bash

gethid=`docker container ls -f name=fullnode -q`

if [[ -n "$gethid" ]]
then
  docker exec -it $gethid sh -c "geth attach --preload=/root/ck.bundle.js /root/geth.ipc"
else
  echo "Geth isn't running.."
fi

