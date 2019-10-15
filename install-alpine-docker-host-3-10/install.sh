#!/bin/sh
cp -f ./repositories /etc/apk/repositories

apk update
apk upgrade

apk add mc virtualbox-guest-additions virtualbox-guest-modules-virt docker py-pip samba findmnt build-base python2-dev libffi-dev openssl-dev libc-dev

# docker install
pip install docker-compose
rc-update add docker boot
mkdir /etc/docker/
cp -f ./daemon.json /etc/docker/daemon.json

# add Linux user
(echo user0; echo user0) | adduser -u 1000 user0

# create mount dirs
mkdir /mnt/docker-persistent-volumes
mkdir /mnt/docker
mkdir /mnt/virtualbox-shared-folder

cat ./fstab >> /etc/fstab

mount /dev/sdb
mount /dev/sdc

mkdir /mnt/docker-persistent-volumes/user0
chown user0:user0 /mnt/docker-persistent-volumes/user0

# samba
cp -f ./smb.conf /etc/samba/smb.conf
(echo user0; echo user0) | smbpasswd -a user0
rc-update add samba
rc-service samba start

# docker start
rc-service docker start

# clean up
rm -f /var/cache/apk/*

