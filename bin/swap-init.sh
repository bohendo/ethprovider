#!/bin/bash

[[ -f /swp ]] || sudo fallocate -l 6G /swp

sudo chmod 600 /swp
sudo mkswap /swp
sudo swapon /swp

free -h

