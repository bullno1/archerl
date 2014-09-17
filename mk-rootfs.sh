#!/bin/sh

set -e

cd $(dirname `readlink -f $0`)
sudo rm -rf rootfs

vagrant_build() {
	echo "Unknown distro, building using vagrant"

	vagrant up
	vagrant ssh -c /vagrant/mk-rootfs.sh
}

host_build() {
	echo "Arch Linux detected, building using the host filesystem"

	# Create the base file system as root
	mkdir rootfs
	sudo pacstrap -c -d rootfs busybox glibc openssl
	sudo pacman --root `pwd`/rootfs --noconfirm -Rdds perl
	sudo sh -c 'chown -R $SUDO_USER:users rootfs'

	# Doing other operations as a normal user
	cd rootfs
	bin/busybox --list | while read cmd
	do
		ln -s /bin/busybox bin/$cmd
	done

	echo "Cleaning up"

	rm -rf usr/share/man
	rm -rf var/lib/pacman
	rm -rf usr/share/doc
	rm -rf usr/include
	rm -rf usr/share/info
	rm -rf etc/pacman.d
	find usr/lib/gconv -type f -and -name '*.so' -and ! -name ANSI_X3.110.so -and ! -name UNICODE.so -exec rm {} \;
	rm usr/lib/*.a
	rm usr/lib/*.o
	find usr/share/i18n/charmaps -type f ! -name ANSI_X3.110-1983.gz -and ! -name UTF-8.gz -exec rm {} \;
	find usr/share/i18n/locales -type f ! -name 'translit_*' -and ! -name en_US -exec rm {} \;
	find usr/share/zoneinfo -type f ! -name UTC -and ! -name '*.tab' -exec rm -rf {} \;
	find usr/share/zoneinfo -type d -empty -delete
	find var/cache -type f -delete
	rm -rf var/log/*
	rm -rf usr/share/iana-etc #doesnt look that important
	rm -rf usr/share/locale #en_US is not using it

	echo "Making rootfs.tar.gz"
	tar -czf ../docker/rootfs.tar.gz *
}

OS_NAME=

read_os_name() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		OS_NAME=$NAME
	fi
}

read_os_name
if [ x"$OS_NAME" == x"Arch Linux" ]; then
	host_build
else
	vagrant_build
fi
