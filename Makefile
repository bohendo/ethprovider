# Specify make-specific variables (VPATH = prerequisite search path)
VPATH=.flags
SHELL=/bin/bash

project=eth

proxy_version=v$(shell grep proxy versions | awk -F '=' '{print $$2}')
geth_version=v$(shell grep geth versions | awk -F '=' '{print $$2}')
lighthouse_version=v$(shell grep lighthouse versions | awk -F '=' '{print $$2}')

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

proxy: versions $(shell find modules/proxy $(find_options))
	$(log_start)
	docker build --file modules/proxy/Dockerfile --tag $(project)_proxy:$(proxy_version) modules/proxy
	$(log_finish) && mv -f $(totalTime) .flags/$@

geth: versions $(shell find modules/geth $(find_options))
	$(log_start)
	docker build --file modules/geth/Dockerfile --build-arg VERSION=$(geth_version) --tag $(project)_geth:$(geth_version) modules/geth
	$(log_finish) && mv -f $(totalTime) .flags/$@

lighthouse: versions $(shell find modules/lighthouse $(find_options))
	$(log_start)
	docker build --file modules/lighthouse/Dockerfile --build-arg VERSION=$(lighthouse_version) --tag $(project)_lighthouse:$(lighthouse_version) modules/lighthouse
	$(log_finish) && mv -f $(totalTime) .flags/$@
