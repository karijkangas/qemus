#!/bin/bash

INDEX="${1:-01}"
BASE_DISK_NAME="${2:-debian12-base.qcow2}"
BASE_OVMF_VARS_NAME="${3:-ovmf_vars.fd}"

DISK="${INDEX}-${BASE_DISK_NAME}"
OVMF_VARS="${INDEX}-${BASE_OVMF_VARS_NAME}"

if [ -z "$QEMUS_HOME" ]; then
    echo "\$QEMUS_HOME not set."
    exit 1
fi

IMAGES_DIR="$QEMUS_HOME"/images
DISKS_DIR="$QEMUS_HOME"/disks

DISK_FILE="$DISKS_DIR"/"$DISK"
OVMF_VARS_FILE="$DISKS_DIR"/"$OVMF_VARS"

cp "$IMAGES_DIR"/"$BASE_OVMF_NAME" "$OVMF_VARS_FILE"
cp "$DISKS_DIR"/"$BASE_DISK_NAME" "$DISK_FILE"

