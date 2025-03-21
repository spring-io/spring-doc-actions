#!/bin/bash

__check_github_repository_owner_usage() {
  echo "usage: check_github_repository_owner.sh [OPTION]...

   --github-repository=REPO       the github repository (e.g. spring-projects/spring-security)
   --ssh-docs-path=PATH           the full path that the docs will be deployed to (e.g. https://docs.spring.io/spring-security/reference/ is \${HTTP_DOCS}/spring-security/reference)
"
}

__check_github_repository_owner_usage_error() {
  echo "Error: $1" >&2
  __check_github_repository_owner_usage
  exit 1
}

__check_github_repository_owner() {
  local github_repository ssh_docs_path valid_args
  valid_args=$(getopt --options '' --long ,github-repository:,ssh-docs-path: -- "$@")
  if [[ $? -ne 0 ]]; then
    __check_github_repository_owner_usage
    exit 1;
  fi

  eval set -- "$valid_args"

  while [ : ]; do
    case "$1" in
      --github-repository)
          github_repository="$2"
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
        __check_github_repository_owner_usage_error "Invalid argument $1 $2"
        ;;
    esac
  done

  if ! [[ "$github_repository" =~  .+/.+ ]]; then
    __check_github_repository_owner_usage_error " '--github-repository' must be in the form of <owner>/<name> but got '$github_repository'"
  fi
  if ! [[ "$ssh_docs_path" =~  ^/.+ ]]; then
    __check_github_repository_owner_usage_error " '--ssh-docs-path' must start with and not equal / but got '$ssh_docs_path'"
  fi

  local marker_file="${ssh_docs_path}/.github-repository"

  if [ -d "$ssh_docs_path" ]; then
    # The path exists so ensure the marker file contents contain github_repository
    local marker_file_content=""
    if [ -f "$marker_file" ]; then
      marker_file_content="$(cat $marker_file)"
    fi
    if [ "$marker_file_content" == "$github_repository" ]; then
      echo "Owner is verified"
      exit 0
    else
      echo "Failed to verify that $ssh_docs_path is owned by $github_repository because the file $marker_file contains $marker_file_content" >&2
      exit 2
    fi
  else
    # The path does not yet exist so create the folder and add the marker file
    echo "Directory $ssh_docs_path does not exist. Marking as owned by $github_repository"
    mkdir -p "$ssh_docs_path"
    echo -n "$github_repository" >$marker_file
    exit 0
  fi

}

__check_github_repository_owner "$@"