## Ethereum providers

## Requirements

The machine on which you'll run any of these deploy scripts needs to have docker installed (and that's it!)

## Usage

To deploy a geth node: `bash deploy-ethprovider.sh geth`

To deploy a parity node: `bash deploy-ethprovider.sh parity`

To deploy a ganache node: `bash launch-testnet.sh`

## Customization

These scripts are each very simple, don't be afraid to dig in and tinker with them until they fit your use case.

The deploy script contains an embedded Dockerfile that simply installs the client of interest, it's unlikely that you'd need to change anything there.

It also contains a `docker service create` command at the end which utilizes both docker-specific options (eg mounting volumes) and provider-specific options (eg setting data directories & api interfaces).

The most commonly changed config options are at the top. Customize the options passed to `docker service create` to your heart's content. Then run the deploy script and you're good to go.
