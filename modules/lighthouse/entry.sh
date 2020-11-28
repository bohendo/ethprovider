#!/bin/sh

lighthouse --network mainnet account validator import --keystore keystore.json

exec lighthouse beacon --http --http-address=0.0.0.0
