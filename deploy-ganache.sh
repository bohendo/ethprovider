#!/bin/bash

me=`whoami`
version=latest

image="$me/ganache:$version"

docker pull $image

docker service create \
  --name "ethprovider_ganache" \
  --mode "global" \
  --network "blog_back" \
  --publish "8545:8545" \
  --mount "type=volume,source=ganache_data,target=/root/ganache" \
  --detach \
  $image

