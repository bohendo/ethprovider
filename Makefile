version=0.2.0
project=ethprovider
registry=docker.io/$(shell whoami)

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
.PHONY: default all simple manual stop clean deploy deploy-live

default: proxy simple
all: proxy simple manual
simple: proxy geth parity
manual: proxy geth-manual parity-manual

stop: 
	bash ops/stop.sh
	docker container prune -f

clean:
	rm -rf build/*

deploy: simple
	docker tag $(project)_proxy:latest $(registry)/$(project)_proxy:latest
	docker tag $(project)_geth:latest $(registry)/$(project)_geth:latest
	docker tag $(project)_parity:latest $(registry)/$(project)_parity:latest
	docker push $(registry)/$(project)_proxy:latest
	docker push $(registry)/$(project)_geth:latest
	docker push $(registry)/$(project)_parity:latest
	bash ops/deploy.sh

deploy-live: all
	docker tag $(project)_database:latest $(registry)/$(project)_database:$(version)
	docker tag $(project)_hub:latest $(registry)/$(project)_hub:$(version)
	docker tag $(project)_proxy:latest $(registry)/$(project)_proxy:$(version)
	docker push $(registry)/$(project)_database:$(version)
	docker push $(registry)/$(project)_hub:$(version)
	docker push $(registry)/$(project)_proxy:$(version)
	MODE=live bash ops/deploy.sh

# Begin Real Rules

proxy: $(shell find $(proxy) $(find_options))
	$(log_start)
	docker build --file $(proxy)/Dockerfile --tag $(project)_proxy:latest $(proxy)
	$(log_finish) && touch build/proxy

geth: $(geth)/simple.Dockerfile $(geth)/entry.sh
	$(log_start)
	docker build --file $(geth)/simple.Dockerfile --tag $(project)_geth:latest $(geth)
	$(log_finish) && touch build/geth

parity: $(parity)/simple.Dockerfile $(parity)/entry.sh
	$(log_start)
	docker build --file $(parity)/simple.Dockerfile --tag $(project)_parity:latest $(parity)
	$(log_finish) && touch build/parity

geth-manual: $(geth)/manual.Dockerfile $(geth)/entry.sh
	$(log_start)
	docker build --file $(geth)/manual.Dockerfile --tag $(project)_geth:latest $(geth)
	$(log_finish) && touch build/geth-manual

parity-manual: $(parity)/manual.Dockerfile $(parity)/entry.sh
	$(log_start)
	docker build --file $(parity)/manual.Dockerfile --tag $(project)_parity:latest $(parity)
	$(log_finish) && touch build/parity-manual
