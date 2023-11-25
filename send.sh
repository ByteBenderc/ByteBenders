#!/bin/bash
# Параметры SSH
REMOTE_HOST="192.168.59.63"
REMOTE_USER="olya"
REMOTE_DIR="/home/olya/desktop/"

# Параметры файла для отправки
LOCAL_FILE="/home/user/secret/logs/*.txt"
#REMOTE_FILE="filename_on_remote_host"

# Отправка файла через SSH
#scp "$LOCAL_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" - строчка не работает, пока указывайте вручную по образцу ниже
scp  /home/user/secret/logs/*.txt olya@192.168.59.63:/home/olya/desktop/
# scp /home/имя вашего пользователя(кого хотите проверить)/secret/logs/*.txt (имя того кому передаете информацию)@(айпи того кому передаете информацию):/home/(имя принимающего информацию)/(папка в которой должны появиться данные)
