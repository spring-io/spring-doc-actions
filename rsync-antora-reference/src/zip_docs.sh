#!/bin/bash

__zip_docs_usage() {
  echo "usage: zip_docs.sh [OPTION]...

   --zip-name=NAME                the name of the zip file to be created
   --ssh-docs-path=PATH           the full path that the docs that should be included in the zip file (e.g. https://docs.spring.io/spring-security/reference/ is \${HTTP_DOCS}/spring-security/reference)
"
}

__zip_docs_usage_error() {
  echo "Error: $1" >&2
  __zip_docs_usage
  exit 1
}

__zip_docs() {
  local zip_name ssh_docs_path valid_args
  valid_args=$(getopt --options '' --long ,zip-name:,ssh-docs-path: -- "$@")
  if [[ $? -ne 0 ]]; then
    __zip_docs_usage
    exit 1;
  fi

  eval set -- "$valid_args"

  while [ : ]; do
    case "$1" in
      --zip-name)
          zip_name="$2"
          shift 2
          ;;
      --ssh-docs-path)
          ssh_docs_path="$2"
          shift 2
          ;;
       --) shift;
          break
          ;;
      *)
        __zip_docs_usage_error "Invalid argument $1 $2"
        ;;
    esac
  done

  if ! [[ "$zip_name" =~  .+\.zip ]]; then
    __zip_docs_usage_error " '--zip-name' must end with .zip but got '$zip_name'"
  fi
  if ! [[ "$ssh_docs_path" =~  ^/.+ ]]; then
    __zip_docs_usage_error " '--ssh-docs-path' must start with / but got '$ssh_docs_path'"
  fi

  if [ -d "$ssh_docs_path" ]; then
    # The path exists
    cd "$ssh_docs_path"
    echo "Zipping content in '$ssh_docs_path' to '$zip_name'"
    zip -r "$zip_name" . *
    cd -
  else
    # The path does not exist so fail
    echo "Error: Directory --ssh-docs-path '$ssh_docs_path' cannot be zipped because it does not exist"
    exit 1
  fi

}

__zip_docs "$@"