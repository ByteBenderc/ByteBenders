#!/bin/bash
chmod +x 3test.sh
#Скачиваем таблицу уязвимостей для дальнейшего анализа с её использованием

wget -O /tmp/vullist.xlsx https://bdu.fstec.ru/files/documents/vullist.xlsx --no-check-certificate

# Указываем путь к файлу vullist.xlsx
vullist_xlsx="/tmp/vullist.xlsx"
vullist_csv="/tmp/vullist.csv"
# Преобразуем XLSX в CSV
vullist_xlsx="$(basename "$vullist" .xlsx).csv"
#xlsx2csv "$vullist_xlsx" > "$vullist_csv"
xlsx2csv /tmp/vullist.xlsx /tmp/vullist.csv

# Получаем список установленных программ в Debian
installed_packages=$(dpkg --get-selections | awk '{print $1}')

# Сопоставляем установленные пакеты с таблицей и создаём отчёт
report_file="/home/user/secret/logs/vulnerability_report.txt"
#rm -f "$report_file"

# Удаляем старый файл отчёта, если он существует
echo "Отчёт о уязвимостях" >> "$report_file"
echo "---------------------------" >> "$report_file"

#while IFS=, read -r package_name vulnerability
#do
#    if [[ " $installed_packages " =~ " $package_name " ]]; then
 #       echo "Установленный пакет: $package_name" >> "$report_file"
  #      echo "Уязвимость: $vulnerability" >> "$report_file"
  #      echo "---" >> "$report_file"
   # fi
#done < "$vullilst_csv"

INSTALLED_PACKAGES_FILE="/home/user/secret/installed_packages.txt"
VULLIST_FILE="/tmp/vullist.csv"
LOG_FILE="/home/user/secret/logs/log.txt"

# Поиск слов из файла installed_packages.txt в vullist.csv с помощью grep и сохранение результата в log.txt
grep -iFf "$INSTALLED_PACKAGES_FILE" "$VULLIST_FILE" > "$LOG_FILE"

echo "Отчёт сгенерирован. Пожалуйста, посмотрите файл $report_file для подробностей."
 

# Узнаем характеристики компьютера после сканирования на уязвимости
echo "=== Характеристики компьютера ==="
echo "Операционная система: $(uname -s)"
echo "Процессор: $(uname -p)"
echo "Общее количество ядер ЦП: $(nproc)"
echo "Общее количество ядер ГПУ: $(nvidia-smi -L | wc -l)"
echo "Объем оперативной памяти: $(free -h | awk '/^Mem/ {print $2}')"

# Узнаем загруженность ЦП
echo "=== Загруженность ЦП ==="
cpu_load="$(top -bn1 | grep '%Cpu' | awk '{print $2}')"
echo "Загрузка ЦП: $cpu_load%"

# Узнаем загруженность ГПУ (для NVIDIA)
gpu_load=""
if command -v nvidia-smi &> /dev/null; then
    echo "=== Загруженность ГПУ ==="
    gpu_load="$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}')"
    echo "Загрузка ГПУ: $gpu_load%"
else
    echo "Драйвер NVIDIA не установлен. Невозможно узнать загруженность ГПУ."
fi

# Сканируем носители данных
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



