#!/usr/bin/env bash

__cleanup_ssh_usage() {
  echo "usage: cleanup_ssh.sh [OPTION]...

   --ssh-private-key-path=PATH    the path to the private key to use
"
}

__cleanup_ssh_usage_error() {
  echo "Error: $1" >&2
  usage
  exit 1
}

__cleanup_ssh() {
  local ssh_private_key_path valid_args
  valid_args=$(getopt --options '' --long ssh-private-key-path: -- "$@")
  if [[ $? -ne 0 ]]; then
    usage
    exit 1;
  fi

  eval set -- "$valid_args"

  while [ : ]; do
    case "$1" in
      --ssh-private-key-path)
          ssh_private_key_path="$2"
          shift 2
          ;;
       --) shift;
          break
          ;;
      *)
        __cleanup_ssh_usage_error "Invalid argument $1 $2"
        ;;
    esac
  done

  rm -f "$ssh_private_key_path"
}

__cleanup_ssh "$@"