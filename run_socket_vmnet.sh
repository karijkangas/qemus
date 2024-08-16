#!/usr/bin/env bash
PREFIX="$(brew --prefix)"
mkdir -p "$PREFIX"/var/run
sudo "$PREFIX"/opt/socket_vmnet/bin/socket_vmnet --vmnet-gateway=192.168.56.1 "$PREFIX"/var/run/socket_vmnet

