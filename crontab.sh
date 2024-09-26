#!/bin/bash

# path to the script needed to be executed
SCRIPT_PATH="/root/AeroBack/backup.sh"

# expression for cron time
CRON_TIME="0 3 * * *"

CRON_JOB="$CRON_TIME $SCRIPT_PATH"

# 检查CRON_JOB是否已经存在，避免重复添加
(crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -

