#!/bin/bash
# Параметры SSH
REMOTE_HOST="192.168.59.63"
REMOTE_USER="olya"
REMOTE_DIR="/home/olya/desktop/"

# Параметры файла для отправки
LOCAL_FILE="/home/user/secret/logs/*.txt"
#REMOTE_FILE="filename_on_remote_host"

# Отправка файла через SSH
#scp "$LOCAL_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"
scp  /home/user/secret/logs/*.txt olya@192.168.59.63:/home/olya/desktop/
