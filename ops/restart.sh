#!/bin/bash
set -e

project=eth

make deploy
bash ops/stop.sh
bash ops/deploy.sh

