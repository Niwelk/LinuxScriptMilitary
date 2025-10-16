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

if [ $# -lt 5 ] && [ $# -gt 1 ]; then
    if [ $(echo "$NEW > $3" | bc -l 2>/dev/null) -eq 1 ]; then
        AR_C="${3:-70}"
        FILES_C="${4:-50}"
        ARCHIVE_PATH="$2"
        NAME="archive_$(date +%Y%m%d_%H%M%S).tar.gz"
        echo "Критерий архивации выполнен (${NEW}% > ${AR_C}%), архивируем."