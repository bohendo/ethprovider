# Ethereum provider

## Requirements

`make` and `docker`

Git clone this repo where you want to deploy it.

## Usage: the essentials

`make` will build everything locally.

Before starting, make sure your lighthouse dir contains a valid `validator_definitions.yml` file w keystores/passwords at the provided paths.

`make start` will start an eth1 client + eth2 beacon + eth2 validator, all behind a proxy which takes care of https certs.

`make stop` will stop both the proxy and provider.
