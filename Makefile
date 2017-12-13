
##### VARIABLES #####

VPATH=build

v=latest

js=$(shell find ./js -type f -name "*.js")

webpack=./node_modules/.bin/webpack

##### RULES #####
# first rule is the default

all: geth
	@true

deploy: geth
	docker build -f geth.Dockerfile -t `whoami`/geth:$v -t geth:$v .
	docker push `whoami`/geth:$v

geth: geth.Dockerfile geth.bundle.js
	docker build -f geth.Dockerfile -t `whoami`/geth:latest -t geth:latest .
	mkdir -p build && touch build/geth

build/geth.bundle.js: $(js) webpack.config.js
	$(webpack) --config webpack.config.js

