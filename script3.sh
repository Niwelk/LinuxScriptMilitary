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