echo "Step 3: Удаление файлов..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        rm -f "$file"
        echo "Удален и добавлен в архив: $file"
    fi
done < "$F_LIST"
find "$F_PATH" -type d -empty -delete
echo "Архивирование и удаление файлов прошло успешно."