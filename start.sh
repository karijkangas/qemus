#!/usr/bin/env bash

source "$( dirname -- "${BASH_SOURCE[0]}" )/env.sh"

if [ -z "$QEMUS_HOME" ]; then
    echo "\$QEMUS_HOME not set."
    exit 1
fi

INDEX="${1:-01}"
MEMORY_SIZE="${2:-4G}"
BASE_DISK_NAME="${3:-debian12-base.qcow2}"
BASE_OVMF_VARS_NAME="${4:-ovmf_vars.fd}"

CORE_COUNT=4
DISK="${INDEX}-${BASE_DISK_NAME}"
OVMF_VARS="${INDEX}-${BASE_OVMF_VARS_NAME}"

DISKS_DIR="$QEMUS_HOME"/disks

DISK_FILE="$DISKS_DIR"/"$DISK"
OVMF_VARS_FILE="$DISKS_DIR"/"$OVMF_VARS"
EFI_FIRM="$(dirname "$(which qemu-img)")/../share/qemu/edk2-aarch64-code.fd"

PREFIX="$(brew --prefix)"
CLIENT=${PREFIX}/opt/socket_vmnet/bin/socket_vmnet_client
SOCKET=${PREFIX}/var/run/socket_vmnet

"${CLIENT}" "${SOCKET}" qemu-system-aarch64 \
  -machine virt,accel=hvf,highmem=on \
  -cpu cortex-a72 -smp "$CORE_COUNT" -m "$MEMORY_SIZE" \
  -device virtio-net-pci,netdev=net0,mac=ca:fe:ba:be:00:"$INDEX" \
  -netdev socket,id=net0,fd=3 \
  -device qemu-xhci,id=usb-bus \
  -device usb-tablet,bus=usb-bus.0 \
  -device usb-mouse,bus=usb-bus.0 \
  -device usb-kbd,bus=usb-bus.0 \
  -device virtio-gpu-pci \
  -device virtio-rng-pci \
  -display default,show-cursor=on \
  -drive format=raw,file="$EFI_FIRM",if=pflash,readonly=on \
  -drive format=raw,file="$OVMF_VARS_FILE",if=pflash \
  -device nvme,drive=drive0,serial=drive0,bootindex=0 \
  -drive if=none,media=disk,id=drive0,format=qcow2,file="$DISK_FILE" \
  -virtfs local,path="$CONFIG_SHARED_FOLDER",security_model=mapped,mount_tag="$CONFIG_MOUNT_TAG" \
  -nographic 

