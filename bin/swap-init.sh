#!/bin/bash

function err { >&2 echo "Error: $1"; exit 1; }
[[ -f /swp ]] && err "Swap already initialized"

sudo fallocate -l 2G /swp
sudo chmod 600 /swp
sudo mkswap /swp
sudo swapon /swp

free -h

