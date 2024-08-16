#!/bin/bash

INDEX="${1:-1}"
MEMORY_SIZE="${2:-4G}"
BASE_DISK_NAME="${3:-debian12.qcow2}"

DISK="${INDEX}-${BASE_DISK_NAME}"
CORE_COUNT=4
OVMF_VARS=ovmf_vars.fd

if [ -z "$QEMUS_HOME" ]; then
    echo "\$QEMUS_HOME not set."
    exit 1
fi

IMAGES_DIR="$QEMUS_HOME"/images
DISKS_DIR="$QEMUS_HOME"/disks
SHARED_FOLDER="$QEMUS_HOME"/vm-share

EFI_FIRM="$(dirname "$(which qemu-img)")/../share/qemu/edk2-aarch64-code.fd"

DISK_FILE="$DISKS_DIR"/"$DISK"
OVMF_VARS_FILE="$IMAGES_DIR"/"$OVMF_VARS"

cp "$DISKS_DIR"/"$BASE_DISK_NAME" "$DISK_FILE"

PREFIX="$(brew --prefix)"
CLIENT=${PREFIX}/opt/socket_vmnet/bin/socket_vmnet_client
SOCKET=${PREFIX}/var/run/socket_vmnet

"${CLIENT}" "${SOCKET}" qemu-system-aarch64 \
  -device virtio-net-pci,netdev=net0 -netdev socket,id=net0,fd=3 \
  -machine virt,accel=hvf,highmem=on \
  -cpu cortex-a72 -smp "$CORE_COUNT" -m "$MEMORY_SIZE" \
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
  -virtfs local,path="$SHARED_FOLDER",security_model=mapped,mount_tag=vm-share \
  -nographic \

