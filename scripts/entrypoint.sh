#!/bin/bash

set -e

BASE_DIR=$(dirname "$(realpath "$0")")

source "$BASE_DIR/utils.sh"

if is_true "$DEBUG_MODE"; then
  set -x
fi

backup() {
  if "$BASE_DIR/backup.sh" "$1" 2>&1 | tee output.log; then
    notify "$BACKUP_SUCCESS_SCRIPT" "$(cat output.log)"
  else
    notify "$BACKUP_FAILED_SCRIPT" "$(cat output.log)"
  fi
}

is_true "$PRE_START_BACKUP" && backup "pre"

# shellcheck disable=SC2068
dotnet /server/VintagestoryServer.dll --dataPath "$DATA_PATH" $@

is_true "$PRE_START_BACKUP" && backup "post"