# Ethereum provider

This repo provides tools & scripts for running a stack of ETH2 validators in production. Currently, only two ETH2 clients are supported (lighthouse & prysm) but more might be added later.

## Requirements

`make` and `docker`

Git clone this repo where you want to deploy it.

## Usage: the essentials

`make` will build everything locally.

Before starting, make sure your lighthouse dir contains a valid `validator_definitions.yml` file w keystores/passwords at the provided paths.

`make start` will start an eth1 client + eth2 beacon + eth2 validator, all behind a proxy which takes care of https certs.

`make stop` will stop both the proxy and provider.

## TODO

- Automate deposit, this probably means wrapping the official deposit CLI in my own script that sends the deposit tx & puts keys in the correct spot

## Open Questions

- How many eth2 beacons should be included? One? One for each distinct validator client? One for each validator?
- Should end users specify which client they want? Or should we auto-use a healthy mixture of supported clients
- Is it worth setting up a way for migrating a validator from one client to another? eg from prysm to lighthouse. (maybe later once things standardize a bit more)
