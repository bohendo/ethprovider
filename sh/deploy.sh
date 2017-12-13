#!/bin/bash

function err { >&2 echo "Error: $1"; exit 1; }

target="$1"

# If we're deploying to localhost things are simpler, just do it
if [ -z "$target" ]
then
  make deploy
  docker stack deploy -c ./docker-compose.yml fullnode
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
make deploy

cat docker-compose.yml | ssh $target "cat - > ~/docker-compose-fullnode.yml"

ssh $target docker pull bohendo/geth:latest

ssh $target 'bash -s' <<EOF
docker stack deploy -c docker-compose-fullnode.yml fullnode
EOF

