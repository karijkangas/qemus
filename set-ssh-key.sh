#!/usr/bin/env bash
if [ $# -lt 3 ]; then
    >&2 echo "Usage: set_ssh_key.sh <user> <key> <hosts>"
    exit 1
fi

USER="$1"
KEY="$2"
shift 2

read -p "User $USER password for ssh-copy-id: " -r -s USERPASS
printf "\n"

for HOST in "$@"; do
    echo "$USERPASS" | sshpass ssh-copy-id -i "$KEY" -f -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER"@"$HOST"
done

