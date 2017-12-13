
##### VARIABLES #####

v=latest

##### RULES #####
# first rule is the default

all: geth
	@true

deploy: geth
	docker build -f geth.Dockerfile -t `whoami`/geth:$v -t geth:$v .
	docker push `whoami`/geth:$v

geth: geth.Dockerfile
	docker build -f geth.Dockerfile -t `whoami`/geth:latest -t geth:latest .
	mkdir -p build && touch build/geth

