
project=ethprovider

proxy_version=$(shell grep proxy versions | awk -F '=' '{print $$2}')
geth_version=$(shell grep geth versions | awk -F '=' '{print $$2}')

# Get absolute paths to important dirs
cwd=$(shell pwd)
geth=$(cwd)/modules/geth
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
.PHONY: default all stop clean deploy deploy-live proxy-logs provider-logs

default: all
all: proxy geth

start:
	bash ops/start.sh

stop: 
	bash ops/stop.sh
	docker container prune -f

clean:
	rm -rf build/*

# Begin Real Rules

proxy: $(shell find $(proxy) $(find_options))
	$(log_start)
	docker build --file $(proxy)/Dockerfile --tag $(project)_proxy:$(proxy_version) $(proxy)
	$(log_finish) && touch build/proxy

geth: $(geth)/Dockerfile $(geth)/entry.sh
	$(log_start)
	docker build --file $(geth)/Dockerfile --build-arg VERSION=$(geth_version) --tag $(project)_geth:$(geth_version) $(geth)
	$(log_finish) && touch build/geth
