#!/bin/bash

gethid=`docker container ls -f name=ethnode -q`

if [[ -n "$gethid" ]]
then
  docker exec -it $gethid sh -c "geth attach --preload=/root/ck.bundle.js /tmp/ipc/geth.ipc"
else
  echo "Geth isn't running.."
fi

