# Ethereum provider

This repo provides tools & scripts for running an ETH1 provider and ETH2 beacon + validators in production. Currently, this repo only supports geth for ETH1 and lighthouse for ETH2.

## Requirements

`make` and `docker`

Git clone this repo where you want to deploy it.

## Usage: the essentials

`make` will build everything locally.

Before starting, make sure your lighthouse dir contains a valid `validator_definitions.yml` file w keystores/passwords at the provided paths.

`make start` will start a geth eth1 client + lighthouse eth2 beacon/validator, all behind a proxy which takes care of https certs.

`make stop` will stop the whole stack including the proxy and all eth providers.

## TODO

- Automate deposit, this probably means wrapping the official deposit CLI in a custom script that also sends the deposit tx & puts keys in the correct spot
