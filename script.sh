#!/bin/bash

if [ $# -eq 0 ]; then
    echo "ERROR: Введите хотя бы 1 аргумент!"
    exit 1
fi
if [ $# -gt 5 ]; then
    echo "ERROR: Введено слишком много аргументов!"
    exit 1
fi
F_PATH="$1"
WORK_MODE="${2:-0}"
if [ ! -d "$F_PATH" ]; then
    echo "ERROR: Папка '$F_PATH' не существует!" >&2
    exit 1
fi
if [ ! -x "/usr/bin/bc" ]; then
    echo "ERROR: bc не установлен в системе. Для работы необходимо установить его через: sudo apt install bc." >&2
    exit 1
fi
if [ $WORK_MODE -eq 0 ]; then
    FOLDER_S=$(du -sb "$F_PATH" 2>/dev/null | cut -f1)
    FS_S=$(df -B1 "$F_PATH" 2>/dev/null | awk 'NR==2 {print $2}')
    if [ -z "$FOLDER_S" ] || [ -z "$FS_S" ]; then
        echo "ERROR: Не удалось вычислить размеры!" >&2
        exit 1
    fi
    PERCENT=$(awk "BEGIN {printf \"%.6f\", ($FOLDER_S * 100) / $FS_S}")
    if [ $(echo "$PERCENT >= 0.1" | bc -l 2>/dev/null) -eq 1 ]; then
        NEW=$(awk "BEGIN {printf \"%.1f\", $PERCENT}")
        echo "Заполненность папки: ${NEW}%"
    elif [ $(echo "$PERCENT >= 0.001" | bc -l 2>/dev/null) -eq 1 ]; then
        NEW=$(awk "BEGIN {printf \"%.3f\", $PERCENT}")
        echo "Заполненность папки: ${NEW}%"
    else
        NEW=$(awk "BEGIN {printf \"%.2e\", $PERCENT}")
        NEW=$(echo "$NEW" | sed 's/e-0/e-/; s/e+0/e/; s/e/ x 10^/;')
        echo "Заполненность папки: ${NEW}%"
        NEW=$(awk "BEGIN {printf \"%.11f\", $PERCENT}")
    fi
else
    dd if=/dev/zero of="/tmp/virtual_disk.img" bs="2G" count=1 >/dev/null 2>&1
    mkfs.ext4 -q "/tmp/virtual_disk.img" >/dev/null 2>&1
    mkdir -p "/mnt/virtual_check"
    mount -o loop "/tmp/virtual_disk.img" "/mnt/virtual_check" >/dev/null 2>&1
    if ! mount | grep -q "/mnt/virtual_check"; then
        echo "ERROR: Не удалось смонтировать виртуальный диск!"
        exit 1
    fi
    if ! cp -r "$F_PATH" "/mnt/virtual_check/" 2>/dev/null; then
        echo "ERROR: Папка не помещается в виртуальный диск 2G!"
        umount "/mnt/virtual_check" >/dev/null 2>&1
        rm -f "/tmp/virtual_disk.img"
        rmdir "/mnt/virtual_check"
        exit 1
    fi
    NEW=$(df "/mnt/virtual_check" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
    if [ "$NEW" -le 1 ]; then
        NEW=0
    fi
    umount "/mnt/virtual_check" >/dev/null 2>&1
    rm -f "/tmp/virtual_disk.img"
    rmdir "/mnt/virtual_check"
    echo "Заполненность папки в виртуальном диске 2G: $NEW%"
fi
if [ $# -lt 6 ] && [ $# -gt 2 ]; then
    if [ $(echo "$NEW > $4" | bc -l 2>/dev/null) -eq 1 ]; then
        AR_C="${4:-70}"
        FILES_C="${5:-50}"
        ARCHIVE_PATH="$3"
        NAME="archive_$(basename "$F_PATH")_$(date +%d.%m.%Y_%H:%M).tar.gz"
        echo "Критерий архивации выполнен (${NEW}% > ${AR_C}%), архивируем."
        F_LIST=$(mktemp)
        find "$F_PATH" -type f -printf "%T@ %p\n" > /tmp/tsf.txt
        sort -n /tmp/tsf.txt > /tmp/tsfs.txt
        head -n "$FILES_C" /tmp/tsfs.txt > /tmp/tsfso.txt
        cut -d' ' -f2- /tmp/tsfso.txt > "$F_LIST"
        mkdir -p "$ARCHIVE_PATH"
        if [ ! -s "$F_LIST" ]; then
            echo "Нет файлов для архивации в указанной папке."
            rm -f "$F_LIST"
            exit 1
        fi
        echo "Найдено файлов для архивации: $(wc -l < "$F_LIST")"
        echo "Step 1: Архивирование..."
        tar -czf "$ARCHIVE_PATH/$NAME" -T "$F_LIST" .
        if [ $? -ne 0 ]; then
            echo "ERROR: Ошибка архивирования!"
            rm -f "$F_LIST"
            exit 1
        fi
        echo "Step 2: Проверка архива..."
        if tar -tzf "$ARCHIVE_PATH/$NAME" > /dev/null; then
            echo "Проверка архива прошла успешно."
            echo "Step 3: Удаление файлов..."
            while IFS= read -r file; do
                if [ -f "$file" ]; then
                    rm -f "$file"
                    echo "Удален и добавлен в архив: $file"
                fi
            done < "$F_LIST"
            find "$F_PATH" -type d -empty -delete
            echo "Архивирование и удаление файлов прошло успешно."
        else
            echo "ERROR: Архив поврежден!"
        fi
        rm -f "$F_LIST"
    else
        echo "Критерий архивации не выполнен, выход из программы."
    fi
fi