# Ethereum provider

## Requirements

`make` and `docker`

## Usage: the essentials

**Build:** `make push` will build everything locally and push the resulting docker images to dockerhub (or you can replace the registry variable at the top of Makefile to push the images somewhere else)

**Deploy:** `make deploy` will pull the necessary docker images from the registry (dockerhub by default) and deploy them. This will deploy an ethprovider (geth) behind an nginx proxy that'll set-up an https connection and log rpc requests. If an ethprovider is already deployed, it will stop the current deployment and redeploy a new one.

`make stop` will stop both the proxy and provider.

## Etc

`make simple` will download the geth docker image and configure them appropriately.

`make manual` will download both client's source code and compile/build them according to their docker files: `modules/**/manual.dockerfile`

(There is a variable at the top of the Makefile that specifies the default mode (manual or simple) that's used during `make push`, it's usually set to manual.)

`bash ops/logs.sh proxy` to view the proxy's logs.

`bash ops/logs.sh provider` to view the ethprovider's logs.
