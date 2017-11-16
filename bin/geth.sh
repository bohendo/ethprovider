#!/bin/bash

function err { >&2 echo "Error: $1"; exit 1; }

ipc="$HOME/.ethereum/geth.ipc"

[[ -e $ipc ]] || err "Run geth-start first"

/usr/bin/geth attach $ipc

