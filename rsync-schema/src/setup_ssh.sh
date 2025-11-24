#!/bin/bash

__setup_ssh_usage() {
  echo "usage: setup_ssh.sh [OPTION]...

   --ssh-private-key-path=PATH    the path to the private key to use
   --ssh-private-key=KEY          the private key to use which will be written to ssh-private-key-path
   --ssh-known-host=KNOWN_HOST    the known host to add to known_hosts file
"
}

__setup_ssh_usage_error() {
  echo "Error: $1" >&2
  __setup_ssh_usage
  exit 1
}

__setup_ssh() {
  local ssh_private_key_path ssh_private_key ssh_known_host valid_args
  VALID_ARGS=$(getopt --options '' --long ssh-private-key-path:,ssh-private-key:,ssh-known-host: -- "$@")
  if [[ $? -ne 0 ]]; then
    __setup_ssh_usage
    exit 1;
  fi

  eval set -- "$VALID_ARGS"

  while [ : ]; do
    case "$1" in
      --ssh-private-key-path)
          ssh_private_key_path="$2"
          shift 2
          ;;
      --ssh-private-key)
          ssh_private_key="$2"
          shift 2
          ;;
      --ssh-known-host)
          ssh_known_host="$2"
          shift 2
          ;;
       --) shift;
          break
          ;;
      *)
        usage_error "Invalid argument $1 $2"
        ;;
    esac
  done

  install -m 600 -D /dev/null "$ssh_private_key_path"
  echo "$ssh_private_key" > "$ssh_private_key_path"
  if [ "$ssh_known_host" != "#" ]; then
    echo "$ssh_known_host" > ~/.ssh/known_hosts
  fi
}

__setup_ssh "$@"