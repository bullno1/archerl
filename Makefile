.PHONY: all

all: docker/rootfs.tar.gz
	docker build docker

docker/rootfs.tar.gz: mk-rootfs.sh
	./mk-rootfs.sh
