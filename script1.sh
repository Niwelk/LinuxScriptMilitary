FOLDER_S=$(du -sb "$F_PATH" 2>/dev/null | cut -f1)
FS_S=$(df -B1 "$F_PATH" 2>/dev/null | awk 'NR==2 {print $2}')
if [ -z "$FOLDER_S" ] || [ -z "$FS_S" ]; then
    echo "Ошибка: Не удалось вычислить размеры!" >&2
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
    NEW=$(echo "$NEW" | sed 's/e/ x 10^/; s/+//; s/-/⁻/')
    echo "Заполненность папки: ${NEW}%"
    NEW=$(awk "BEGIN {printf \"%.11f\", $PERCENT}")
fi