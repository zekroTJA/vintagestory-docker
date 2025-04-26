#!/bin/bash

WDIR=/tmp/backup

set -e

BASE_DIR=$(dirname "$(realpath "$0")")

source "$BASE_DIR/utils.sh"

if is_true "$DEBUG_MODE"; then
  set -x
fi

backup_location="${BACKUP_LOCATION:-/var/vinstagestory/}"

if [ -f /run/secrets/rcloneconfig ]; then
    if [ -d "$backup_location" ]; then
        echo -e "\n[${CYAN} INFO ${RESET}] Starting backup"
        mkdir -p "$WDIR"

        FILENAME="$1-$(date +"$(eval echo "${BACKUP_FILE_FORMAT}")").zip"

        # Start zipping server
        zip -9rq "${WDIR}/$FILENAME" "$backup_location"

        # Rclone move
        echo -e "\n[${CYAN} INFO ${RESET}] Start uploading of backup $FILENAME"
        rclone --config /run/secrets/rcloneconfig move "${WDIR}/$FILENAME" "$BACKUP_TARGET" -v

        echo -e "\n[${CYAN} INFO ${RESET}] Cleaning up old backups"
        rclone --config /run/secrets/rcloneconfig --min-age "$MAX_AGE_BACKUP_FILES" delete "$BACKUP_TARGET" -v

        # Delete WDIR
        rm -rf "$WDIR"
        echo -e "\n[${CYAN} INFO ${RESET}] Finished backup"
    else
        echo -e "\n[${CYAN} INFO ${RESET}] Minecraft server is not initialized"
    fi

else
    echo -e "\n[${CYAN} INFO ${RESET}] Backup is disabled"
fi

exit 0