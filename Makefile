
project=ethprovider
registry=docker.io/$(shell whoami)

proxy_version=$(shell grep proxy versions | awk -F '=' '{print $$2}')
geth_version=$(shell grep geth versions | awk -F '=' '{print $$2}')
parity_version=$(shell grep parity versions | awk -F '=' '{print $$2}')

proxy_image=$(registry)/$(project)_proxy:$(proxy_version)
parity_image=$(registry)/$(project)_parity:$(parity_version)

# Get absolute paths to important dirs
cwd=$(shell pwd)
geth=$(cwd)/modules/geth
parity=$(cwd)/modules/parity
proxy=$(cwd)/modules/proxy

# Specify make-specific variables (VPATH = prerequisite search path)
VPATH=build
SHELL=/bin/bash

# Env setup
find_options=-type f -not -path "*/node_modules/*" -not -name "*.swp" -not -path "*/.*"
$(shell mkdir -p build)

log_start=@echo "=============";echo "[Makefile] => Start building $@"; date "+%s" > build/.timestamp
log_finish=@echo "[Makefile] => Finished building $@ in $$((`date "+%s"` - `cat build/.timestamp`)) seconds";echo "=============";echo

# Begin Phony Rules
.PHONY: default all prebuilt manual stop clean deploy deploy-live proxy-logs provider-logs

default: proxy prebuilt
all: proxy prebuilt manual
prebuilt: proxy geth-prebuilt parity-prebuilt
manual: proxy geth-manual parity-manual

start:
	bash ops/start.sh

stop: 
	bash ops/stop.sh
	docker container prune -f

clean:
	rm -rf build/*

push-proxy: proxy
	docker tag $(project)_proxy:$(proxy_version) $(proxy_image)
	docker push $(proxy_image)

push-prebuilt: prebuilt
	docker tag $(project)_geth:s$(geth_version) $(registry)/$(project)_geth:s$(geth_version)
	docker tag $(project)_parity:s$(parity_version) $(registry)/$(project)_parity:s$(parity_version)
	docker push $(registry)/$(project)_geth:s$(geth_version)
	docker push $(registry)/$(project)_parity:s$(parity_version)

push-manual: manual
	docker tag $(project)_geth:s$(geth_version) $(registry)/$(project)_geth:s$(geth_version)
	docker tag $(project)_parity:s$(parity_version) $(registry)/$(project)_parity:s$(parity_version)
	docker push $(registry)/$(project)_geth:s$(geth_version)
	docker push $(registry)/$(project)_parity:s$(parity_version)

deploy:
	bash ops/stop.sh
	bash ops/deploy.sh

# Begin Real Rules

proxy: $(shell find $(proxy) $(find_options))
	$(log_start)
	docker build --file $(proxy)/Dockerfile --tag $(project)_proxy:$(proxy_version) $(proxy)
	$(log_finish) && touch build/proxy

geth-manual: $(geth)/manual.Dockerfile $(geth)/entry.sh
	$(log_start)
	docker build --file $(geth)/manual.Dockerfile --build-arg VERSION=$(geth_version) --tag $(project)_geth:m$(geth_version) $(geth)
	$(log_finish) && touch build/geth-manual

geth-prebuilt: $(geth)/prebuilt.Dockerfile $(geth)/entry.sh
	$(log_start)
	docker build --file $(geth)/prebuilt.Dockerfile --build-arg VERSION=$(geth_version) --tag $(project)_geth:s$(geth_version) $(geth)
	$(log_finish) && touch build/geth

parity-manual: $(parity)/manual.Dockerfile $(parity)/entry.sh
	$(log_start)
	docker build --file $(parity)/manual.Dockerfile --build-arg VERSION=$(parity_version) --tag $(project)_parity:m$(parity_version) $(parity)
	$(log_finish) && touch build/parity-manual

parity-prebuilt: $(parity)/prebuilt.Dockerfile $(parity)/entry.sh
	$(log_start)
	docker build --file $(parity)/prebuilt.Dockerfile --build-arg VERSION=$(parity_version) --tag $(project)_parity:s$(parity_version) $(parity)
	$(log_finish) && touch build/parity
