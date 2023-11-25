#!/bin/bash
chmod +x 3test.sh
#Скачиваем таблицу уязвимостей

wget -O /tmp/vullist.xlsx https://bdu.fstec.ru/files/documents/vullist.xlsx --no-check-certificate

# Указываем путь к таблице
vullist_xlsx="/tmp/vullist.xlsx"
vullist_csv="/tmp/vullist.csv"
# Здеся случается хрясь бум и бам с xlsx на csv
vullist_xlsx="$(basename "$vullist" .xlsx).csv"

xlsx2csv /tmp/vullist.xlsx /tmp/vullist.csv

#Получаем файлы, установленные на камутер
installed_packages=$(dpkg --get-selections | awk '{print $1}')

# Здеся программа проверяет файлы на уязвимости и делает отчёт
report_file="/home/user/secret/logs/vulnerability_report.txt"


echo "Отчёт о уязвимостях" >> "$report_file"
echo "---------------------------" >> "$report_file"

INSTALLED_PACKAGES_FILE="/home/user/secret/installed_packages.txt"
VULLIST_FILE="/tmp/vullist.csv"
LOG_FILE="/home/user/secret/logs/log.txt"

# А вот тута из файла (instakked pakages file) уязвимости записываются в логи (log)
grep -iFf "$INSTALLED_PACKAGES_FILE" "$VULLIST_FILE" > "$LOG_FILE"

echo "Отчёт сгенерирован. Пожалуйста, посмотрите файл $report_file для подробностей."
 

# Узнаем характеристики компьтера, сканируем внешние носители, уязвимости не уйдут от нас, не уйдут
echo "=== Характеристики компьютера ==="
echo "Операционная система: $(uname -s)"
echo "Процессор: $(uname -p)"
echo "Общее количество ядер ЦП: $(nproc)"
echo "Общее количество ядер ГПУ: $(nvidia-smi -L | wc -l)"
echo "Объем оперативной памяти: $(free -h | awk '/^Mem/ {print $2}')"

# Узнаем как сильно страдает цп(Цыпа-паук)
echo "=== Загруженность ЦП ==="
cpu_load="$(top -bn1 | grep '%Cpu' | awk '{print $2}')"
echo "Загрузка ЦП: $cpu_load%"

# Узнаем загруженность ГПУ
gpu_load=""
if command -v nvidia-smi &> /dev/null; then
    echo "=== Загруженность ГПУ ==="
    gpu_load="$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}')"
    echo "Загрузка ГПУ: $gpu_load%"
else
    echo "Драйвер NVIDIA не установлен. Невозможно узнать загруженность ГПУ."
fi

# Сканируем носители данных чтобы уязвимости не спрятались
echo "=== Сканирование носителей данных ==="
drives="$(lsblk -o NAME,TYPE,SIZE,MOUNTPOINT | grep -vE 'rom|loop')"
echo "$drives"

# Создаем отчет
report="=== Отчет загрузки ЦП, ГПУ и носителей данных ===\n"
report+="Характеристики компьютера:\n"
report+="Операционная система: $(uname -s)\n"
report+="Процессор: $(uname -p)\n"
report+="Общее количество ядер ЦП: $(nproc)\n"
report+="Общее количество ядер ГПУ: $(nvidia-smi -L | wc -l)\n"
report+="Объем оперативной памяти: $(free -h | awk '/^Mem/ {print $2}')\n"
report+="\n"
report+="Загрузка ЦП: $cpu_load%\n"
report+="Загрузка ГПУ: $gpu_load%\n"
report+="\n"
report+="Носители данных:\n$drives\n"

# Сохраняем отчет в текстовый файл
echo -e "$report" > /home/user/secret/logs/ra.txt

 /bin/bash /home/user/secret/send.sh



