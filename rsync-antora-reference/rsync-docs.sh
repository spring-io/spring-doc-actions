#!/bin/bash

SSH_HOST="$1"
SSH_HOST_PATH="$2"
SSH_PRIVATE_KEY="$3"
SSH_KNOWN_HOST="$4"
DRY_RUN="$5"
FROM="$6"

SSH_PRIVATE_KEY_PATH="$HOME/.ssh/${GITHUB_REPOSITORY:-publish-docs}"

if [ "$#" -ne 6 ]; then
  echo -e "not enough arguments USAGE:\n\n$0 \$SSH_HOST \$SSH_HOST_PATH \$SSH_PRIVATE_KEY \$SSH_KNOWN_HOST \$DRY_RUN \$DOC_PATH\n\n" >&2
  exit 1
fi
if [ -z "$SSH_HOST" ]; then
  echo -e "SSH_HOST was empty string"
  exit 1
fi
if [ -z "$SSH_HOST_PATH" ]; then
  echo -e "SSH_HOST_PATH was empty string"
  exit 1
fi
if [ -z "$SSH_PRIVATE_KEY" ]; then
  echo -e "SSH_PRIVATE_KEY was empty string"
  exit 1
fi
if [ -z "$SSH_KNOWN_HOST" ]; then
  echo -e "SSH_KNOWN_HOST was empty string"
  exit 1
fi

(
  set -e
  set -f
  install -m 600 -D /dev/null "$SSH_PRIVATE_KEY_PATH"
  echo "$SSH_PRIVATE_KEY" > "$SSH_PRIVATE_KEY_PATH"
  if [ "$SSH_KNOWN_HOST" != "#" ]; then
    echo "$SSH_KNOWN_HOST" > ~/.ssh/known_hosts
  fi
  RSYNC_OPTS='-avz --delete '
  if [ "$DRY_RUN" != "false" ]; then
    RSYNC_OPTS="$RSYNC_OPTS --dry-run "
  fi
  if [ -d "$FROM/.cache" ]; then
    RSYNC_OPTS="$RSYNC_OPTS$(find $FROM/.cache -printf ' --include /.cache/%P')"
  fi
  RSYNC_OPTS="$RSYNC_OPTS --exclude /.cache --exclude /.cache/* "
  if [ -n "$BUILD_REFNAME" ]; then
    RSYNC_OPTS="-c $RSYNC_OPTS$(find $FROM -mindepth 1 -maxdepth 1 \! -name 404.html \! -name '.*' -type f -printf ' --include /%P')"
    RSYNC_OPTS="$RSYNC_OPTS$(find $FROM -mindepth 1 -maxdepth 1 -type d \! -name _ -printf ' --include /%P --include /%P/**') --exclude **"
  fi
  rsync $RSYNC_OPTS -e "ssh -i $SSH_PRIVATE_KEY_PATH" $FROM/ "$SSH_HOST:$SSH_HOST_PATH"
)
exit_code=$?

rm -f "$SSH_PRIVATE_KEY_PATH"

exit $exit_code