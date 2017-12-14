
##### VARIABLES #####

VPATH=build

v=$(shell grep "\"version\"" ./package.json | egrep -o [0-9.]*)

js=$(shell find ./js -type f -name "*.js")

webpack=./node_modules/.bin/webpack

##### RULES #####
# first rule is the default

all: server client
	@true

deploy: server client
	docker build -f server.Dockerfile -t `whoami`/ethnode_server:$v -t ethnode_server:$v .
	docker push `whoami`/ethnode_server:$v

server: server.Dockerfile
	docker build -f server.Dockerfile -t `whoami`/ethnode_server:latest -t ethnode_server:latest .
	mkdir -p build && touch build/server

client: client.Dockerfile ck.bundle.js
	docker build -f client.Dockerfile -t `whoami`/ethnode_client:latest -t ethnode_client:latest .
	mkdir -p build && touch build/client

build/ck.bundle.js: node_modules webpack.config.js $(js)
	$(webpack) --config webpack.config.js

node_modules: package.json
	npm install

