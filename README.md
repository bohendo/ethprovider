## Ethereum providers

## Requirements

The machine on which you'll run any of these deploy scripts needs to have docker installed (and that's it!)

## Usage

To deploy a geth node: `bash deploy-geth.sh`

To deploy a parity node: `bash deploy-parity.sh`

To deploy a ganache node: `bash deploy-ganache.sh`

## Customization

These scripts are all very simple, well under 50 lines of code each.

Each contains an embedded Dockerfile that simply installs the client of interest, it's unlikely that you'd need to change anything there.

Each script contains a `docker service create` command at the end which utilizes both docker-specific options (eg mounting volumes) and provider-specific options (eg setting data directories & ipc paths).

Customize the options passed to `docker service create` to your heart's content. Then run the deploy script and you're good to go.

The `geth` script will attach a geth console to some provider. Pass some file.js as it's first & only argument to preload that script into your console.

The first line of `geth` specifies the provider (ie 'geth' or 'parity') and looks for an appropriately named ipc socket file created by the associated deploy script.
