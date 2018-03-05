#!/bin/bash

me=`whoami`
version=latest

image="$me/ganache:$version"

docker pull $image

docker service create \
  --name "ethprovider_ganache" \
  --mode "global" \
  --publish "7545:7545" \
  --detach \
  $image

