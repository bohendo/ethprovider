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
version=0.2.0

log_start=@echo "=============";echo "[Makefile] => Start building $@"; date "+%s" > build/.timestamp
log_finish=@echo "[Makefile] => Finished building $@ in $$((`date "+%s"` - `cat build/.timestamp`)) seconds";echo "=============";echo

# Begin Phony Rules
.PHONY: default all dev prod clean stop purge deploy deploy-live test

default: all
all: proxy geth parity

stop: 
	bash ops/stop.sh
	docker container prune -f

clean:
	rm -rf build/*

deploy: all
	docker tag $(project)_proxy:latest $(registry)/$(project)_proxy:latest
	docker tag $(project)_geth:latest $(registry)/$(project)_geth:latest
	docker tag $(project)_parity:latest $(registry)/$(project)_parity:latest
	docker push $(registry)/$(project)_proxy:latest
	docker push $(registry)/$(project)_geth:latest
	docker push $(registry)/$(project)_parity:latest

deploy-live: all
	docker tag $(project)_database:latest $(registry)/$(project)_database:$(version)
	docker tag $(project)_hub:latest $(registry)/$(project)_hub:$(version)
	docker tag $(project)_proxy:latest $(registry)/$(project)_proxy:$(version)
	docker push $(registry)/$(project)_database:$(version)
	docker push $(registry)/$(project)_hub:$(version)
	docker push $(registry)/$(project)_proxy:$(version)

# Begin Real Rules

proxy: $(shell find $(proxy) $(find_options))
	$(log_start)
	docker build --file $(proxy)/Dockerfile --tag $(project)_proxy:latest $(proxy)
	$(log_finish) && touch build/proxy

geth: $(geth)/Dockerfile
	$(log_start)
	docker build --file $(geth)/Dockerfile --tag $(project)_geth:latest $(geth)
	$(log_finish) && touch build/geth

parity: $(parity)/Dockerfile
	$(log_start)
	docker build --file $(parity)/Dockerfile --tag $(project)_parity:latest $(parity)
	$(log_finish) && touch build/parity

