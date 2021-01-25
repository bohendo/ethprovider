# Ethereum provider

This repo provides tools & scripts for running a stack of ETH2 validators in production. Currently, only two ETH2 client implementations are supported (lighthouse & prysm) but more might be added later.

Important convention: lighthouse handles even path indexes, prysm handles odd ones. Indexing starts at zero, therefore if only a single validator is being run (index=0), lighthouse will be used. If another validator is added (index=1), prysm will be used & this pattern continues back & forth.

## Requirements

`make` and `docker`

Git clone this repo where you want to deploy it.

## Usage: the essentials

`make` will build everything locally.

Before starting, make sure your lighthouse dir contains a valid `validator_definitions.yml` file w keystores/passwords at the provided paths.

`make start` will start a geth eth1 client + lighthouse eth2 beacon/validator + prysm eth2 beacon/validator, all behind a proxy which takes care of https certs.

`make stop` will stop the whole stack including the proxy and all eth providers.

## TODO

- Automate deposit, this probably means wrapping the official deposit CLI in a custom script that also sends the deposit tx & puts keys in the correct spot
- Add sanity check on startup to ensure that the same key is not being used by multiple client implementation

## Open Questions

- How many eth2 beacons should be included? One? One for each distinct validator client?
- Should end users specify which client they want? Or should we auto-use a healthy mixture of supported clients?
- Is it worth setting up a way for migrating a validator from one client to another? Eg from prysm to lighthouse. (maybe later once things standardize a bit more)
