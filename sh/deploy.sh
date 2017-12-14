#!/bin/bash

function err { >&2 echo "Error: $1"; exit 1; }

target="$1"
v=$(grep "\"version\"" ./package.json | egrep -o [0-9.]*)

# If we're deploying to localhost things are simpler, just do it
if [ -z "$target" ]
then
  touch js/* && make deploy
  cat docker-compose.yml | sed 's/image: geth:latest/image: '`whoami`'\/geth:'"$v"'/' > /tmp/docker-compose-fullnode.yml
  docker stack deploy -c /tmp/docker-compose-fullnode.yml fullnode
  exit 0
fi

# Don't deploy if there are uncommitted changes
if [[ `git status --short | wc -l` -ne 0 ]]
then
  err "Commit your changes first"
fi

# Make sure we can ssh to the machine we're deploying to
if ! ssh -q $target exit 2> /dev/null
then
  err "Couldn't open an ssh connection to $target"
fi

# Make sure project gets rebuilt as the production version
touch js/* && make deploy

cat docker-compose.yml |\
  sed 's/image: geth:latest/image: '`whoami`'\/geth:'"$v"'/' |\
  ssh $target "cat - > ~/docker-compose-fullnode.yml"

ssh $target docker pull `whoami`/geth:$v

ssh $target 'bash -s' <<EOF
docker stack deploy -c docker-compose-fullnode.yml fullnode
EOF

