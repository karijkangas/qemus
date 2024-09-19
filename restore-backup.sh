#!/usr/bin/env bash

source "$( dirname -- "${BASH_SOURCE[0]}" )/env.sh"

if [ -z "$QEMUS_HOME" ]; then
    echo "\$QEMUS_HOME not set."
    exit 1
fi

INDEX="${1:-01}"

DISKS_DIR="$QEMUS_HOME"/disks
BACKUP_DIR="$QEMUS_HOME"/backup_${INDEX}

cp -r "$BACKUP_DIR" "$DISKS_DIR" 

