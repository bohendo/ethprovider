
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

geth: geth.Dockerfile ck.bundle.js
	docker build -f geth.Dockerfile -t `whoami`/geth:latest -t geth:latest .
	mkdir -p build && touch build/geth

build/ck.bundle.js: node_modules webpack.config.js $(js)
	$(webpack) --config webpack.config.js

node_modules: package.json
	npm install

