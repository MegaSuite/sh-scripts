#!/bin/bash

# get the environment variables
source /root/AeroBack/config.ini

# back up the timezone settings
if [ -f /etc/localtime ]; then
    sudo mv /etc/localtime /etc/localtime.bak
    echo "已备份现有的时区设置到 /etc/localtime.bak"
fi

# set timezone: Asia/Shanghai
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# set hardware clock as UTC
sudo timedatectl set-local-rtc 0

# restart cron
sudo systemctl restart cron

# check the time zone
CURRENT_TIMEZONE=$(date +"%Z %z")
echo "当前时区已更改为: ${CURRENT_TIMEZONE}"

# generate the filename for backup files
CURRENT_DATE=$(date "+%Y%m%d_%H%M%S")
FILE_NAME=${FILE_PREFIX}_${CURRENT_DATE}.${ARCHIVE_FORMAT}

# compress
tar -C "${SRC_DIR}" --exclude=${EXCLUDED} -czf "${FILE_NAME}" ${INCLUDED}

# transfer
scp -P "${SSH_PORT}" "${FILE_NAME}" "${SSH_USER}@${BACKUP_SERVER}:${DST_DIR}"

# remove the backup files in local storage
rm -f "${FILE_NAME}"

# limited number of remote backup files
ssh -p "${SSH_PORT}" "${SSH_USER}@${BACKUP_SERVER}" "ls -t ${DST_DIR}/${FILE_PREFIX}* | tail -n +4 | xargs --no-run-if-empty rm -f"

