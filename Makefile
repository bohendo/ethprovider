
project=eth

proxy_version=v$(shell grep proxy versions | awk -F '=' '{print $$2}')
geth_version=v$(shell grep geth versions | awk -F '=' '{print $$2}')
prysm_version=v$(shell grep prysm versions | awk -F '=' '{print $$2}')
lighthouse_version=v$(shell grep lighthouse versions | awk -F '=' '{print $$2}')

# Get absolute paths to important dirs
cwd=$(shell pwd)
geth=$(cwd)/modules/geth
proxy=$(cwd)/modules/proxy

# Specify make-specific variables (VPATH = prerequisite search path)
VPATH=.flags
SHELL=/bin/bash

# Env setup
find_options=-type f -not -path "*/node_modules/*" -not -name "*.swp" -not -path "*/.*"
$(shell mkdir -p .flags)

startTime=.flags/.startTime
totalTime=.flags/.totalTime
log_start=@echo "=============";echo "[Makefile] => Start building $@"; date "+%s" > $(startTime)
log_finish=@echo $$((`date "+%s"` - `cat $(startTime)`)) > $(totalTime); rm $(startTime); echo "[Makefile] => Finished building $@ in `cat $(totalTime)` seconds";echo "=============";echo

# Begin Phony Rules
.PHONY: default all stop clean deploy deploy-live proxy-logs provider-logs

default: all
all: proxy geth lighthouse

start:
	bash ops/start.sh

stop: 
	bash ops/stop.sh
	docker container prune -f

restart: stop
	bash ops/start.sh

clean:
	rm -rf .flags/*

# Begin Real Rules

proxy: $(shell find $(proxy) $(find_options))
	$(log_start)
	docker build --file $(proxy)/Dockerfile --tag $(project)_proxy:$(proxy_version) $(proxy)
	$(log_finish) && mv -f $(totalTime) .flags/$@

geth: versions $(geth)/Dockerfile $(geth)/entry.sh
	$(log_start)
	docker build --file $(geth)/Dockerfile --build-arg VERSION=$(geth_version) --tag $(project)_geth:$(geth_version) $(geth)
	$(log_finish) && mv -f $(totalTime) .flags/$@

lighthouse: versions $(shell find modules/lighthouse $(find_options))
	$(log_start)
	docker build --file modules/lighthouse/Dockerfile --build-arg VERSION=$(lighthouse_version) --tag $(project)_lighthouse:$(lighthouse_version) modules/lighthouse
	$(log_finish) && mv -f $(totalTime) .flags/$@

prysm: prysm_beacon prysm_beacon

prysm_beacon: versions $(shell find modules/prysm $(find_options))
	$(log_start)
	docker build --file modules/prysm/beacon.Dockerfile --build-arg VERSION=$(prysm_version) --tag $(project)_prysm_beacon:$(prysm_version) modules/prysm
	$(log_finish) && mv -f $(totalTime) .flags/$@

prysm_validator: versions $(shell find modules/prysm $(find_options))
	$(log_start)
	docker build --file modules/prysm/validator.Dockerfile --build-arg VERSION=$(prysm_version) --tag $(project)_prysm_validator:$(prysm_version) modules/prysm
	$(log_finish) && mv -f $(totalTime) .flags/$@
