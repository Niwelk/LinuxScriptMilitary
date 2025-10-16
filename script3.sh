if [ $# -lt 5 ] && [ $# -gt 1 ]; then
    if [ $(echo "$NEW > $3" | bc -l 2>/dev/null) -eq 1 ]; then
        AR_C="${3:-70}"
        FILES_C="${4:-50}"
        ARCHIVE_PATH="$2"
        NAME="archive_$(date +%Y%m%d_%H%M%S).tar.gz"
        echo "Критерий архивации выполнен (${NEW}% > ${AR_C}%), архивируем."

        F_LIST=$(mktemp)
        find "$F_PATH" -type f -printf "%T@ %p\n" > /tmp/tsf.txt
        sort -n /tmp/tsf.txt > /tmp/tsfs.txt
        head -n "$FILE_COUNT" /tmp/tsfs.txt > /tmp/tsfso.txt
        cut -d' ' -f2- /tmp/tsfso.txt > "$FILE_LIST"
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