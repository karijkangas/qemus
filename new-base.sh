#!/usr/bin/env bash

# This script creates a fresh virtual machine disk file and
# an empty file for persisting UEFI variables.
#
# DEBIAN 12 NOTES:
#   type "exit" from UEFI Interactive Shell
#   select Boot Manager | UEFI QEMU USB HARDDRIVE ...
#   select Install

source "$( dirname -- "${BASH_SOURCE[0]}" )/env.sh"

if [ -z "$QEMUS_HOME" ]; then
    echo "\$QEMUS_HOME not set."
    exit 1
fi

DISK_SIZE="${1:-20G}"
DISK="${2:-debian12-base}".qcow2
ISO_IMAGE_SRC="${3:-https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-12.7.0-arm64-netinst.iso}"

CORE_COUNT=4
MEMORY_SIZE=4G

ISO_IMAGE=$(basename "$ISO_IMAGE_SRC")
EFI_FIRM="$(dirname "$(which qemu-img)")/../share/qemu/edk2-aarch64-code.fd"
OVMF_VARS=ovmf_vars.fd

IMAGES_DIR="$QEMUS_HOME"/images
DISKS_DIR="$QEMUS_HOME"/disks
SHARED_FOLDER="$QEMUS_HOME"/vm-share

ISO_IMAGE_FILE="$IMAGES_DIR/$ISO_IMAGE"
DISK_FILE="$DISKS_DIR"/"$DISK"
OVMF_VARS_FILE="$DISKS_DIR"/"$OVMF_VARS"

mkdir -p "$IMAGES_DIR" "$DISKS_DIR" "$SHARED_FOLDER"

if [ -f "$ISO_IMAGE_FILE" ]; then
	while true; do
  	  read -r -p "ISO image exists, download again? " yn
    	case $yn in
      	    [Yy]* ) rm -f "$ISO_IMAGE_FILE"; break;;
            [Nn]* ) break;;
            [Aa]* ) exit 0;;
        	* ) echo "Please answer yes or no or abort";;
    	esac
    done
fi

wget -nc -P "$IMAGES_DIR" "$ISO_IMAGE_SRC" || { echo "invalid ISO image: $ISO_IMAGE_SRC"; exit 1; }

if [ -f "$DISK_FILE" ] || [ -f "$OVMF_VARS_FILE" ]; then
	while true; do
  	  read -r -p "Delete existing VM disk image and UEFI variables? " yn
    	case $yn in
      	    [Yy]* ) rm -f "$DISK_FILE" "$OVMF_VARS_FILE"; break;;
            [Nn]* ) exit;;
        	* ) echo "Please answer yes or no.";;
    	esac
	done
fi

qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"
dd if=/dev/zero conv=sync bs=1M count=64 of="$OVMF_VARS_FILE"

qemu-system-aarch64 \
  -machine virt,accel=hvf,highmem=on \
  -cpu cortex-a72 -smp "$CORE_COUNT" -m "$MEMORY_SIZE" \
  -device qemu-xhci,id=usb-bus \
  -device usb-tablet,bus=usb-bus.0 \
  -device usb-mouse,bus=usb-bus.0 \
  -device usb-kbd,bus=usb-bus.0 \
  -device virtio-gpu-pci \
  -device virtio-rng-pci \
  -display default,show-cursor=on \
  -nic user,model=virtio \
  -drive format=raw,file="$EFI_FIRM",if=pflash,readonly=on \
  -drive format=raw,file="$OVMF_VARS_FILE",if=pflash \
  -device nvme,drive=drive0,serial=drive0,bootindex=0 \
  -drive if=none,media=disk,id=drive0,format=qcow2,file="$DISK_FILE" \
  -device usb-storage,drive=drive2,removable=true,bootindex=2 \
  -drive if=none,media=cdrom,id=drive2,file="$ISO_IMAGE_FILE" \
  -nographic

