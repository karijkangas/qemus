#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export QEMUS_HOME=$SCRIPT_DIR

HOSTS_INI="$( dirname -- "${BASH_SOURCE[0]}" )/hosts.ini"

source <(grep \
    -e config_shared_folder \
    -e config_mount_tag \
    "$HOSTS_INI")

export CONFIG_SHARED_FOLDER=$config_shared_folder
export CONFIG_MOUNT_TAG=$config_mount_tag

